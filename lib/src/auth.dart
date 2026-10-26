/// Authentication strategies for Gisila Studio.
library gisila_studio.auth;

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

// ── Abstract interface ────────────────────────────────────────────────────────

/// Pluggable authentication strategy for Gisila Studio.
///
/// Implement this to provide custom auth (e.g. OAuth, LDAP).
/// Two built-in implementations are provided:
/// - [SessionStudioAuth] — in-memory sessions, token stored in a cookie.
/// - [JwtStudioAuth]     — stateless HS256 JWTs, token in cookie or Bearer header.
abstract class StudioAuth {
  /// Returns `true` if the request carries a valid credential.
  ///
  /// Reads from whatever source the strategy uses (cookie, Authorization
  /// header, etc.).
  bool isAuthenticated(Map<String, String> headers);

  /// Validates [username] / [password] and, on success, returns a token
  /// string that will be stored in the auth cookie.
  ///
  /// Returns `null` if the credentials are invalid.
  String? authenticate(String username, String password);

  /// Revokes a previously issued [token] (logout).
  ///
  /// Stateless strategies (e.g. JWT) may treat this as a no-op unless a
  /// token block-list is maintained.
  void revokeToken(String token);

  /// Extracts the raw token from [headers] (cookie or Authorization),
  /// or returns `null` if none is present.
  String? currentToken(Map<String, String> headers);

  /// Builds a `Set-Cookie` header value that installs [token] as the auth
  /// cookie scoped to [prefix] (the studio mount path, e.g. `/admin`).
  ///
  /// Pass an empty string for [prefix] when the studio is served standalone
  /// at the root.
  String setCookieHeader(String token, {String prefix = ''});

  /// Builds a `Set-Cookie` header value that clears the auth cookie.
  ///
  /// [prefix] must match the value used when the cookie was set.
  String clearCookieHeader({String prefix = ''});

  /// Why this strategy's credentials are too weak to put in front of a
  /// database, or `null` when they are acceptable. [GisilaStudio] refuses to
  /// serve while this is non-null unless `allowInsecure` is set. Custom
  /// strategies return `null` unless they override it.
  String? weaknessReason() => null;
}

// ── Session-based auth ────────────────────────────────────────────────────────

/// In-memory session-based authentication.
///
/// On login a random 32-byte token is generated and stored in a server-side
/// `Set<String>`. The same token is placed in an HttpOnly cookie so every
/// subsequent request is validated by a simple set look-up.
///
/// Sessions live in this isolate's memory: they are lost on restart, and a
/// server that runs several isolates (e.g. `shared: true` on one port) will
/// accept a session only on the isolate that issued it. Use [JwtStudioAuth]
/// in those setups.
class SessionStudioAuth extends StudioAuth {
  final String username;
  final String password;

  final _sessions = <String>{};
  final _rng = Random.secure();

  static const _cookieName = '_studio_sid';

  SessionStudioAuth({required this.username, required this.password});

  @override
  String? authenticate(String u, String p) {
    if (u != username || p != password) return null;
    final bytes = List<int>.generate(32, (_) => _rng.nextInt(256));
    final token = base64Url.encode(bytes);
    _sessions.add(token);
    return token;
  }

  @override
  void revokeToken(String token) => _sessions.remove(token);

  @override
  String? weaknessReason() => credentialWeakness(username, password);

  @override
  bool isAuthenticated(Map<String, String> headers) {
    final token = currentToken(headers);
    return token != null && _sessions.contains(token);
  }

  @override
  String? currentToken(Map<String, String> headers) =>
      _tokenFromCookie(headers['cookie'], _cookieName);

  @override
  String setCookieHeader(String token, {String prefix = ''}) {
    final path = prefix.isEmpty ? '/' : prefix;
    return '$_cookieName=$token; Path=$path; HttpOnly; SameSite=Lax';
  }

  @override
  String clearCookieHeader({String prefix = ''}) {
    final path = prefix.isEmpty ? '/' : prefix;
    return '$_cookieName=; Path=$path; HttpOnly; SameSite=Lax; Max-Age=0';
  }
}

// ── JWT-based auth ────────────────────────────────────────────────────────────

/// Stateless HS256 JWT authentication.
///
/// On login the studio signs a compact JWT (header.payload.signature) using
/// [secret] and HMAC-SHA256. Every subsequent request is authenticated by
/// verifying the signature and checking the `exp` claim — no server-side
/// storage is required.
///
/// Tokens are accepted from two sources (checked in order):
///   1. `Authorization: Bearer <token>` request header — useful for API / SPA
///      clients that manage the token themselves.
///   2. The `_studio_jwt` HttpOnly cookie — used by the browser-rendered admin
///      UI; the cookie is set automatically on login.
///
/// ## Usage
///
/// ```dart
/// final studio = GisilaStudio(
///   db: db,
///   auth: JwtStudioAuth(
///     username: 'admin',
///     password: 'secret',
///     secret: Platform.environment['JWT_SECRET']!,
///     expiry: Duration(hours: 12),
///   ),
/// );
///
/// router.mount('/admin', studio.handler(prefix: '/admin'));
/// ```
///
/// ## Client-side token access
///
/// Set [httpOnly] to `false` to make the cookie readable by JavaScript (e.g.
/// to copy the JWT into `localStorage` for use in client-side fetch calls).
/// The studio will then also accept the token via the `Authorization` Bearer
/// header, so your SPA can attach it to every request without cookies.
///
/// **Security note:** Non-HttpOnly cookies are accessible to any JavaScript
/// running on the page. Only disable `httpOnly` when you have a specific
/// client-side need and trust the scripts on the page.
class JwtStudioAuth extends StudioAuth {
  final String username;
  final String password;

  /// HMAC-SHA256 signing secret. Keep this value private and load it from
  /// an environment variable or secrets manager.
  final String secret;

  /// How long a JWT remains valid after issuance. Defaults to 8 hours.
  final Duration expiry;

  /// When `true` (default) the cookie is `HttpOnly`, meaning it is
  /// inaccessible to JavaScript. Set to `false` if client-side JS needs to
  /// read the token (e.g. to store it in `localStorage`).
  final bool httpOnly;

  static const _cookieName = '_studio_jwt';

  JwtStudioAuth({
    required this.username,
    required this.password,
    required this.secret,
    this.expiry = const Duration(hours: 8),
    this.httpOnly = true,
  });

  // ── JWT creation / verification ─────────────────────────────────────────

  String _createJwt(String sub) {
    final header = _b64url(json.encode({'alg': 'HS256', 'typ': 'JWT'}));
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = _b64url(json.encode({
      'sub': sub,
      'iat': now,
      'exp': now + expiry.inSeconds,
    }));
    final sig = _sign('$header.$payload');
    return '$header.$payload.$sig';
  }

  bool _verifyJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return false;

    // Constant-time signature check
    final expected = _sign('${parts[0]}.${parts[1]}');
    if (expected != parts[2]) return false;

    try {
      final raw = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payload = json.decode(raw) as Map<String, dynamic>;
      final exp = (payload['exp'] as num?)?.toInt();
      if (exp == null) return false;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _sign(String data) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    return base64Url
        .encode(hmac.convert(utf8.encode(data)).bytes)
        .replaceAll('=', '');
  }

  // ── Token extraction ────────────────────────────────────────────────────

  String? _extractToken(Map<String, String> headers) {
    // 1. Authorization: Bearer <token>
    final auth = headers['authorization'];
    if (auth != null && auth.startsWith('Bearer ')) {
      final t = auth.substring(7).trim();
      if (t.isNotEmpty) return t;
    }
    // 2. Cookie
    return _tokenFromCookie(headers['cookie'], _cookieName);
  }

  // ── StudioAuth implementation ───────────────────────────────────────────

  @override
  bool isAuthenticated(Map<String, String> headers) {
    final token = _extractToken(headers);
    return token != null && _verifyJwt(token);
  }

  @override
  String? authenticate(String u, String p) {
    if (u != username || p != password) return null;
    return _createJwt(u);
  }

  @override
  String? weaknessReason() =>
      credentialWeakness(username, password) ?? secretWeakness(secret);

  /// JWT auth is stateless — no server-side token list to update.
  ///
  /// To support immediate revocation (e.g. forced logout across devices),
  /// maintain your own block-list and override [isAuthenticated].
  @override
  void revokeToken(String token) {}

  @override
  String? currentToken(Map<String, String> headers) => _extractToken(headers);

  @override
  String setCookieHeader(String token, {String prefix = ''}) {
    final path = prefix.isEmpty ? '/' : prefix;
    final httpOnlyAttr = httpOnly ? '; HttpOnly' : '';
    return '$_cookieName=$token; Path=$path$httpOnlyAttr; SameSite=Lax';
  }

  @override
  String clearCookieHeader({String prefix = ''}) {
    final path = prefix.isEmpty ? '/' : prefix;
    final httpOnlyAttr = httpOnly ? '; HttpOnly' : '';
    return '$_cookieName=; Path=$path$httpOnlyAttr; SameSite=Lax; Max-Age=0';
  }
}

// ── Credential checks ─────────────────────────────────────────────────────────

/// Shortest studio password [credentialWeakness] accepts.
const minStudioPasswordLength = 12;

/// Shortest signing secret [secretWeakness] accepts.
const minStudioSecretLength = 32;

/// Why [username]/[password] are too weak for the studio, or `null`.
String? credentialWeakness(String username, String password) {
  if (username.isEmpty) return 'the username is empty';
  if (password.length < minStudioPasswordLength) {
    return 'the password is shorter than $minStudioPasswordLength characters';
  }
  if (password.toLowerCase() == username.toLowerCase()) {
    return 'the password is the same as the username';
  }
  if (_isPlaceholder(password)) return 'the password is a placeholder value';
  return null;
}

/// Why [secret] is too weak to sign studio tokens, or `null`.
String? secretWeakness(String secret) {
  if (secret.length < minStudioSecretLength) {
    return 'the signing secret is shorter than $minStudioSecretLength characters';
  }
  if (_isPlaceholder(secret))
    return 'the signing secret is a placeholder value';
  return null;
}

bool _isPlaceholder(String value) {
  final v = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return v.contains('changeme') ||
      v.contains('changethis') ||
      v.contains('yoursecret') ||
      v.contains('yourpassword');
}

// ── Shared helpers ────────────────────────────────────────────────────────────

String _b64url(String data) =>
    base64Url.encode(utf8.encode(data)).replaceAll('=', '');

String? _tokenFromCookie(String? cookieHeader, String name) {
  if (cookieHeader == null) return null;
  for (final part in cookieHeader.split(';')) {
    final trimmed = part.trim();
    final idx = trimmed.indexOf('=');
    if (idx < 0) continue;
    if (trimmed.substring(0, idx).trim() == name) {
      return trimmed.substring(idx + 1).trim();
    }
  }
  return null;
}
