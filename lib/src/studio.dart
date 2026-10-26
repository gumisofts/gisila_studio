/// `GisilaStudio` — the main entry point for mounting the admin interface.
library gisila_studio.studio;

import 'dart:io';

import 'package:gisila_orm/gisila.dart';
import 'package:shelf/shelf.dart';

import 'auth.dart';
import 'handler.dart';
import 'model_admin.dart';
import 'ui/login_page.dart';

/// Web-based admin interface for gisila models, inspired by Django admin.
///
/// ## Quick start
///
/// ```dart
/// import 'package:gisila_studio/gisila_studio.dart';
/// import 'package:shelf_router/shelf_router.dart';
///
/// final studio = GisilaStudio(db: db, title: 'Blog Admin');
///
/// studio.register<User>(
///   UserTable.metadata,
///   displayName: 'User',
///   listDisplay: ['id', 'first_name', 'email', 'date_joined'],
///   searchFields: ['first_name', 'last_name', 'email'],
///   readonlyFields: ['id', 'date_joined'],
/// );
///
/// studio.register<Post>(
///   PostTable.metadata,
///   listDisplay: ['id', 'title', 'author_id', 'published_at'],
///   searchFields: ['title'],
///   ordering: ['-published_at'],
/// );
///
/// // Mount under /admin on your existing router
/// // (prefix must match the mount path):
/// router.mount('/admin', studio.handler(prefix: '/admin'));
///
/// // Or serve standalone (no parent router):
/// await shelf_io.serve(studio.handler(prefix: ''), 'localhost', 8080);
/// ```
class GisilaStudio {
  final Database _db;

  /// Title shown in the sidebar header and browser tab.
  final String title;

  /// Auth strategy. When non-null every request is gated behind a login form.
  ///
  /// Pass a [JwtStudioAuth] for stateless JWT authentication or a
  /// [SessionStudioAuth] for server-side session tokens.  When omitted the
  /// convenience [username] / [password] parameters (or their corresponding
  /// `STUDIO_USERNAME` / `STUDIO_PASSWORD` env vars) are used to build a
  /// [SessionStudioAuth] automatically.
  final StudioAuth? _auth;

  final List<ModelAdmin<dynamic>> _admins = [];

  /// Creates a [GisilaStudio] instance.
  ///
  /// **Auth options (pick one):**
  ///
  /// 1. Pass a fully configured [auth] strategy — [JwtStudioAuth] or a custom
  ///    [StudioAuth] implementation.
  ///
  /// ```dart
  /// GisilaStudio(
  ///   db: db,
  ///   auth: JwtStudioAuth(
  ///     username: 'admin',
  ///     password: 's3cr3t',
  ///     secret: Platform.environment['JWT_SECRET']!,
  ///   ),
  /// )
  /// ```
  ///
  /// 2. Use the shorthand [username] / [password] parameters (or the env vars
  ///    `STUDIO_USERNAME` / `STUDIO_PASSWORD`). With a [secret] (or
  ///    `STUDIO_SECRET`) they build a [JwtStudioAuth], which works across
  ///    isolates; without one, a [SessionStudioAuth], which suits a
  ///    single-isolate server only.
  ///
  /// **Refusing insecure setups:** the studio serves a "disabled" page
  /// (HTTP 503) instead of the admin, and logs why to stderr, when
  ///
  /// * no auth is configured, unless [allowUnauthenticated] is `true`
  ///   (local development only); or
  /// * the credentials are weak (see [StudioAuth.weaknessReason]: passwords
  ///   under 12 characters, equal to the username or a placeholder, signing
  ///   secrets under 32 characters), unless [allowInsecure] is `true` or the
  ///   `GISILA_ALLOW_INSECURE=1` env var is set.
  ///
  /// The rest of the app keeps running either way.
  GisilaStudio({
    required Database db,
    this.title = 'Gisila Studio',
    StudioAuth? auth,
    String? username,
    String? password,
    String? secret,
    this.allowUnauthenticated = false,
    bool? allowInsecure,
  })  : _db = db,
        allowInsecure = allowInsecure ??
            Platform.environment['GISILA_ALLOW_INSECURE'] == '1',
        _auth = auth ?? _buildAuth(username, password, secret);

  /// Serve the studio with no login at all. Anyone who can reach it gets
  /// full read/write access to every registered table.
  final bool allowUnauthenticated;

  /// Serve the studio even when [StudioAuth.weaknessReason] objects. Defaults
  /// to the `GISILA_ALLOW_INSECURE=1` env var.
  final bool allowInsecure;

  static StudioAuth? _buildAuth(
      String? username, String? password, String? secret) {
    final env = Platform.environment;
    final u = username ?? env['STUDIO_USERNAME'];
    final p = password ?? env['STUDIO_PASSWORD'];
    final s = secret ?? env['STUDIO_SECRET'];
    if (u == null || u.isEmpty || p == null || p.isEmpty) return null;
    if (s != null && s.isNotEmpty) {
      return JwtStudioAuth(username: u, password: p, secret: s);
    }
    return SessionStudioAuth(username: u, password: p);
  }

  /// Why the studio refuses to serve, or `null` when it will. Warnings for
  /// setups that are allowed but insecure go to stderr.
  String? _disabledReason() {
    final auth = _auth;
    if (auth == null) {
      if (allowUnauthenticated) {
        stderr.writeln('gisila_studio: WARNING: "$title" has no login; anyone '
            'who can reach it can read and change every registered table.');
        return null;
      }
      return 'no login is configured. Set STUDIO_USERNAME and '
          'STUDIO_PASSWORD, or pass auth:. For local development only, pass '
          'allowUnauthenticated: true.';
    }
    final weakness = auth.weaknessReason();
    if (weakness == null) return null;
    if (allowInsecure) {
      stderr.writeln('gisila_studio: WARNING: "$title" is served with weak '
          'credentials ($weakness) because allowInsecure is set.');
      return null;
    }
    return 'its login is too weak: $weakness. Use a password of at least '
        '$minStudioPasswordLength characters and a signing secret of at '
        'least $minStudioSecretLength. To override, pass allowInsecure: true '
        'or set GISILA_ALLOW_INSECURE=1.';
  }

  /// Register a model with the admin.
  ///
  /// [meta] is the `TableMeta<T>` generated by build_runner (e.g.
  /// `UserTable.metadata`).
  ///
  /// Optional parameters mirror Django's `ModelAdmin` class:
  ///
  /// * [displayName] — human-readable singular name, e.g. `"User"`.
  /// * [displayNamePlural] — human-readable plural, e.g. `"Users"`.
  /// * [listDisplay] — which columns appear in the list view (default: first 6).
  /// * [searchFields] — columns to `ILIKE` search against.
  /// * [readonlyFields] — columns shown on forms but not editable.
  /// * [excludeFields] — columns completely hidden from forms.
  /// * [passwordFields] — columns holding secrets: masked and never
  ///   pre-filled on forms, hidden from the default list view and the delete
  ///   page, and kept as-is when left blank on edit. Defaults to columns
  ///   whose name contains `password`, `passwd` or `secret`; pass
  ///   `const []` to opt out.
  /// * [autoNowOnUpdateFields] — columns automatically stamped with the current
  ///   UTC timestamp on every save (create or update). Typically used together
  ///   with [readonlyFields] so the user cannot edit the value manually while
  ///   the studio still keeps it up-to-date, e.g. `['updatedAt']`.
  /// * [pageSize] — rows per page (default 25).
  /// * [ordering] — default list ordering; prefix with `-` for DESC,
  ///   e.g. `['-date_joined', 'email']`.
  void register<T>(
    TableMeta<T> meta, {
    String? displayName,
    String? displayNamePlural,
    List<String>? listDisplay,
    List<String> searchFields = const [],
    List<String> readonlyFields = const [],
    List<String> excludeFields = const [],
    List<String>? passwordFields,
    List<String> autoNowOnUpdateFields = const [],
    int pageSize = 25,
    List<String> ordering = const [],
    String? group,
  }) {
    _admins.add(buildModelAdmin<T>(
      meta,
      displayName: displayName,
      displayNamePlural: displayNamePlural,
      listDisplay: listDisplay,
      searchFields: searchFields,
      readonlyFields: readonlyFields,
      excludeFields: excludeFields,
      passwordFields: passwordFields,
      autoNowOnUpdateFields: autoNowOnUpdateFields,
      pageSize: pageSize,
      ordering: ordering,
      group: group,
    ));
  }

  /// Build the Shelf [Handler] for the admin interface.
  ///
  /// [prefix] must match the URL path where the handler is mounted so that
  /// all internal links are generated correctly.
  ///
  /// ```dart
  /// // Mounted under /admin:
  /// router.mount('/admin', studio.handler(prefix: '/admin'));
  ///
  /// // Standalone (no parent router):
  /// await shelf_io.serve(studio.handler(prefix: ''), 'localhost', 8080);
  /// ```
  Handler handler({required String prefix}) {
    // Normalise: no trailing slash.
    final p =
        prefix.endsWith('/') ? prefix.substring(0, prefix.length - 1) : prefix;

    final disabled = _disabledReason();
    if (disabled != null) {
      stderr.writeln('gisila_studio: "$title" is disabled: $disabled');
      final page = renderDisabledPage(prefix: p, studioTitle: title);
      return (Request _) => Response(
            503,
            body: page,
            headers: {'content-type': 'text/html; charset=utf-8'},
          );
    }

    return buildStudioHandler(
      admins: List.unmodifiable(_admins),
      db: _db,
      prefix: p,
      title: title,
      auth: _auth,
    );
  }
}
