/// Shelf route handlers for Gisila Studio.
library gisila_studio.handler;

import 'dart:math' show max;

import 'package:gisila_orm/gisila.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'column_info.dart';
import 'model_admin.dart';
import 'ui/dashboard.dart';
import 'ui/form_page.dart';
import 'ui/layout.dart';
import 'ui/list_page.dart';
import 'ui/login_page.dart';

/// Build and return the Shelf [Handler] for Gisila Studio.
Handler buildStudioHandler({
  required List<ModelAdmin<dynamic>> admins,
  required Database db,
  required String prefix,
  required String title,
  StudioAuth? auth,
}) {
  final adminByTable = {for (final a in admins) a.meta.tableName: a};

  // ── Helpers ──────────────────────────────────────────────────────────

  DbContext newCtx() => db.context();

  /// Row counts for the sidebar and overview, fetched on every page. Small
  /// tables get an exact COUNT(*); a table Postgres estimates (from
  /// `pg_class.reltuples`, kept by ANALYZE/autovacuum) at
  /// [_exactCountLimit] rows or more shows that estimate instead, so a big
  /// table doesn't cost a full scan per page view.
  Future<Map<String, int>> fetchCounts() async {
    final counts = <String, int>{};
    final c = newCtx();
    final estimates = <String, int>{};
    try {
      final result = await c.execute(
        'SELECT t AS name, cls.reltuples::bigint AS est '
        'FROM unnest(\$1::text[]) AS t '
        'LEFT JOIN pg_class cls ON cls.oid = to_regclass(quote_ident(t))',
        parameters: [
          [for (final a in admins) a.meta.tableName],
        ],
      );
      for (final row in result) {
        final m = row.toColumnMap();
        final est = m['est'];
        if (est is num) estimates[m['name'] as String] = est.toInt();
      }
    } catch (_) {
      // Fall back to exact counts below.
    }
    for (final a in admins) {
      final estimate = estimates[a.meta.tableName] ?? -1;
      if (estimate >= _exactCountLimit) {
        counts[a.meta.tableName] = estimate;
        continue;
      }
      try {
        final result = await c.execute(
          'SELECT COUNT(*)::bigint AS c FROM "${a.meta.tableName}"',
        );
        counts[a.meta.tableName] =
            (result.first.toColumnMap()['c'] as num).toInt();
      } catch (_) {
        counts[a.meta.tableName] = 0;
      }
    }
    return counts;
  }

  Future<List<ColumnInfo>> fetchColumns(String tableName) =>
      fetchColumnInfo(tableName, newCtx());

  Response html(String body, {int status = 200}) => Response(
        status,
        body: body,
        headers: {'content-type': 'text/html; charset=utf-8'},
      );

  Response redir(String location) => Response.found(location);

  Map<String, String> qparams(Request req) => req.requestedUri.queryParameters;

  Future<Map<String, String>> bodyParams(Request req) async {
    final raw = await req.readAsString();
    return Uri.splitQueryString(raw);
  }

  Future<Map<String, List<String>>> bodyParamsMulti(Request req) async {
    final raw = await req.readAsString();
    final result = <String, List<String>>{};
    for (final pair in raw.split('&')) {
      if (pair.isEmpty) continue;
      final idx = pair.indexOf('=');
      if (idx < 0) continue;
      final key = Uri.decodeQueryComponent(pair.substring(0, idx));
      final val = Uri.decodeQueryComponent(pair.substring(idx + 1));
      result.putIfAbsent(key, () => []).add(val);
    }
    return result;
  }

  Object parsePk(ModelAdmin<dynamic> admin, String pk) =>
      int.tryParse(pk) ?? pk;

  Future<Map<String, dynamic>?> fetchRow(
      ModelAdmin<dynamic> admin, String pk) async {
    final result = await newCtx().execute(
      'SELECT * FROM "${admin.meta.tableName}" '
      'WHERE "${admin.meta.primaryKey}" = \$1 LIMIT 1',
      parameters: [parsePk(admin, pk)],
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  // ── Route handlers ───────────────────────────────────────────────────

  // GET /  →  Dashboard
  Future<Response> dashboard(Request req) async {
    final counts = await fetchCounts();
    return html(renderDashboard(
      admins: admins,
      counts: counts,
      prefix: prefix,
      studioTitle: title,
      showLogout: auth != null,
    ));
  }

  // GET /<table>/  →  List view
  Future<Response> listView(Request req, String table) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    final params = qparams(req);
    final rawQ = params['q']?.trim();
    final searchQuery = (rawQ?.isEmpty ?? true) ? null : rawQ;
    // page=0 or a negative page would give a negative OFFSET (a 500).
    final page = max(1, int.tryParse(params['page'] ?? '1') ?? 1);
    final offset = (page - 1) * admin.pageSize;

    final colInfos = await fetchColumns(table);
    final colMap = {for (final c in colInfos) c.name: c};

    final searchClauses = admin.searchFields
        .where((f) => colMap.containsKey(f))
        .map((f) => '("$f"::text ILIKE \$1)')
        .toList();

    final whereClause = searchQuery != null && searchClauses.isNotEmpty
        ? 'WHERE ${searchClauses.join(' OR ')}'
        : '';
    final searchParam =
        searchQuery != null ? <Object?>['%$searchQuery%'] : <Object?>[];

    final c = newCtx();

    final countSql =
        'SELECT COUNT(*)::bigint AS c FROM "${table}" $whereClause';
    final countResult = await c.execute(countSql, parameters: searchParam);
    final totalCount = (countResult.first.toColumnMap()['c'] as num).toInt();

    final rowsSql = 'SELECT * FROM "${table}" $whereClause '
        'ORDER BY ${admin.orderBySql} '
        'LIMIT ${admin.pageSize} OFFSET $offset';
    final rowsResult = await c.execute(rowsSql, parameters: searchParam);
    final rows = rowsResult.map((r) => r.toColumnMap()).toList();

    final counts = await fetchCounts();
    final (flashMessage, flashIsError) =
        parseFlashMessage(qparams(req)['_msg']);

    return html(renderListPage(
      admin: admin,
      allAdmins: admins,
      rows: rows,
      totalCount: totalCount,
      page: page,
      pageSize: admin.pageSize,
      searchQuery: searchQuery,
      columns: colInfos,
      modelCounts: counts,
      prefix: prefix,
      studioTitle: title,
      flashMessage: flashMessage,
      flashIsError: flashIsError,
      showLogout: auth != null,
    ));
  }

  // GET /<table>/add/  →  Add form
  Future<Response> addForm(Request req, String table) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    final colInfos = await fetchColumns(table);
    final counts = await fetchCounts();

    return html(renderFormPage(
      admin: admin,
      allAdmins: admins,
      columns: colInfos,
      modelCounts: counts,
      prefix: prefix,
      studioTitle: title,
      showLogout: auth != null,
    ));
  }

  // POST /<table>/add/  →  Process add
  Future<Response> processAdd(Request req, String table) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    final params = await bodyParams(req);
    final action = params['_action'] ?? 'save';
    final colInfos = await fetchColumns(table);
    final colMap = {for (final c in colInfos) c.name: c};

    final values = <String, Object?>{};
    final errors = <String, String>{};

    for (final colName in admin.meta.columnNames) {
      if (!admin.isEditable(colName)) continue;
      if (colName == admin.meta.primaryKey) continue;

      final info = colMap[colName];
      final rawVal = params[colName];

      try {
        final value = info == null ? rawVal : info.parseFormValue(rawVal);
        if (!identical(value, ColumnInfo.useDefault)) values[colName] = value;
      } on FormatException catch (e) {
        errors[colName] = e.message;
      }
    }

    if (errors.isNotEmpty) {
      final counts = await fetchCounts();
      return html(
        renderFormPage(
          admin: admin,
          allAdmins: admins,
          columns: colInfos,
          modelCounts: counts,
          prefix: prefix,
          studioTitle: title,
          fieldErrors: errors,
          flashMessage: 'Please correct the errors below.',
          flashIsError: true,
          showLogout: auth != null,
        ),
        status: 422,
      );
    }

    // Auto-stamp any declared auto-now fields with the current UTC time.
    final now = DateTime.now().toUtc();
    for (final col in admin.autoNowOnUpdateFields) {
      values[col] = now;
    }

    try {
      final result = await newCtx().execute(
        _buildInsertSql(table, values),
        parameters: values.values.toList(),
      );
      final newRow = result.isNotEmpty ? result.first.toColumnMap() : null;
      final newPk = newRow?[admin.meta.primaryKey]?.toString();

      return switch (action) {
        'save_continue' when newPk != null => redir(
            '$prefix/$table/${Uri.encodeComponent(newPk)}/change/?_msg=added'),
        'save_add' => redir('$prefix/$table/add/'),
        _ => redir('$prefix/$table/?_msg=added'),
      };
    } catch (e) {
      final counts = await fetchCounts();
      return html(
        renderFormPage(
          admin: admin,
          allAdmins: admins,
          columns: colInfos,
          modelCounts: counts,
          prefix: prefix,
          studioTitle: title,
          flashMessage: 'Database error: ${e.toString().split('\n').first}',
          flashIsError: true,
          showLogout: auth != null,
        ),
        status: 500,
      );
    }
  }

  // GET /<table>/<pk>/change/  →  Edit form
  Future<Response> changeForm(Request req, String table, String pk) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    final row = await fetchRow(admin, pk);
    if (row == null) {
      return Response.notFound('${admin.displayName} with pk=$pk not found');
    }

    final colInfos = await fetchColumns(table);
    final counts = await fetchCounts();
    final (flashMessage, flashIsError) =
        parseFlashMessage(qparams(req)['_msg']);

    return html(renderFormPage(
      admin: admin,
      allAdmins: admins,
      columns: colInfos,
      modelCounts: counts,
      prefix: prefix,
      studioTitle: title,
      existingRow: row,
      pkValue: pk,
      flashMessage: flashMessage,
      flashIsError: flashIsError,
      showLogout: auth != null,
    ));
  }

  // POST /<table>/<pk>/change/  →  Process edit
  Future<Response> processChange(Request req, String table, String pk) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    final params = await bodyParams(req);
    final action = params['_action'] ?? 'save';
    final colInfos = await fetchColumns(table);
    final colMap = {for (final c in colInfos) c.name: c};

    final values = <String, Object?>{};
    final errors = <String, String>{};

    for (final colName in admin.meta.columnNames) {
      if (!admin.isEditable(colName)) continue;
      if (colName == admin.meta.primaryKey) continue;

      final info = colMap[colName];
      final rawVal = params[colName];
      // Password inputs are never pre-filled, so blank means "keep".
      if (admin.passwordFields.contains(colName) &&
          (rawVal == null || rawVal.isEmpty)) {
        continue;
      }

      try {
        final value = info == null ? rawVal : info.parseFormValue(rawVal);
        if (!identical(value, ColumnInfo.useDefault)) values[colName] = value;
      } on FormatException catch (e) {
        errors[colName] = e.message;
      }
    }

    if (errors.isNotEmpty) {
      final row = await fetchRow(admin, pk);
      final counts = await fetchCounts();
      return html(
        renderFormPage(
          admin: admin,
          allAdmins: admins,
          columns: colInfos,
          modelCounts: counts,
          prefix: prefix,
          studioTitle: title,
          existingRow: row,
          pkValue: pk,
          fieldErrors: errors,
          flashMessage: 'Please correct the errors below.',
          flashIsError: true,
          showLogout: auth != null,
        ),
        status: 422,
      );
    }

    // Auto-stamp any declared auto-now fields with the current UTC time.
    final now = DateTime.now().toUtc();
    for (final col in admin.autoNowOnUpdateFields) {
      values[col] = now;
    }

    if (values.isEmpty) {
      return redir(
          '$prefix/$table/${Uri.encodeComponent(pk)}/change/?_msg=saved');
    }

    try {
      await newCtx().execute(
        _buildUpdateSql(table, admin.meta.primaryKey, values),
        parameters: [...values.values, parsePk(admin, pk)],
      );

      return switch (action) {
        'save_continue' =>
          redir('$prefix/$table/${Uri.encodeComponent(pk)}/change/?_msg=saved'),
        'save_add' => redir('$prefix/$table/add/'),
        _ => redir('$prefix/$table/?_msg=saved'),
      };
    } catch (e) {
      final row = await fetchRow(admin, pk);
      final counts = await fetchCounts();
      return html(
        renderFormPage(
          admin: admin,
          allAdmins: admins,
          columns: colInfos,
          modelCounts: counts,
          prefix: prefix,
          studioTitle: title,
          existingRow: row,
          pkValue: pk,
          flashMessage: 'Database error: ${e.toString().split('\n').first}',
          flashIsError: true,
          showLogout: auth != null,
        ),
        status: 500,
      );
    }
  }

  // GET /<table>/<pk>/delete/  →  Delete confirmation
  Future<Response> deleteConfirm(Request req, String table, String pk) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    final row = await fetchRow(admin, pk);
    if (row == null) return redir('$prefix/$table/');

    final counts = await fetchCounts();

    final rowSummary = row.entries
        .where((e) => !admin.passwordFields.contains(e.key))
        .take(5)
        .map((e) => '${_esc(e.key)}: ${_esc(e.value?.toString() ?? '—')}')
        .join('\n');

    final body = '''
      <div class="dialog" role="alertdialog" aria-labelledby="del-title">
        <div class="dialog-body">
          <div class="dialog-label">${_esc(admin.displayName)}</div>
          <h2 id="del-title">Delete this record?</h2>
          <p>The record below will be permanently removed from the database. This cannot be undone.</p>
          <div class="code-snippet">$rowSummary</div>
        </div>
        <div class="btn-set">
          <a class="btn btn-secondary" href="$prefix/$table/${Uri.encodeComponent(pk)}/change/">Cancel</a>
          <form method="post" action="$prefix/$table/${Uri.encodeComponent(pk)}/delete/" style="display:contents">
            <button class="btn btn-danger" type="submit">Delete</button>
          </form>
        </div>
      </div>''';

    return html(renderLayout(
      title: 'Delete ${admin.displayName}',
      body: body,
      prefix: prefix,
      admins: admins,
      modelCounts: counts,
      activeTable: table,
      studioTitle: title,
      topbarBreadcrumbs: [
        (admin.displayNamePlural, '$prefix/$table/'),
        (pk, '$prefix/$table/${Uri.encodeComponent(pk)}/change/'),
        ('Delete', null),
      ],
      showLogout: auth != null,
    ));
  }

  // POST /<table>/<pk>/delete/  →  Process delete
  Future<Response> processDelete(Request req, String table, String pk) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    try {
      await newCtx().execute(
        'DELETE FROM "${table}" WHERE "${admin.meta.primaryKey}" = \$1',
        parameters: [parsePk(admin, pk)],
      );
    } catch (_) {
      // Redirect regardless; the row may already be gone.
    }

    return redir('$prefix/$table/?_msg=deleted');
  }

  // POST /<table>/action/  →  Bulk actions
  Future<Response> bulkAction(Request req, String table) async {
    final admin = adminByTable[table];
    if (admin == null) return Response.notFound('Model not registered: $table');

    final multi = await bodyParamsMulti(req);
    final action = multi['action']?.lastOrNull ?? '';
    final ids = multi['ids'] ?? [];

    if (action == 'delete' && ids.isNotEmpty) {
      final placeholders = ids.indexed.map((e) => '\$${e.$1 + 1}').join(', ');
      final typedIds = ids.map<Object>((id) => int.tryParse(id) ?? id).toList();
      await newCtx().execute(
        'DELETE FROM "${table}" '
        'WHERE "${admin.meta.primaryKey}" IN ($placeholders)',
        parameters: typedIds,
      );
    }

    return redir('$prefix/$table/?_msg=action');
  }

  // ── Router assembly ──────────────────────────────────────────────────

  final router = Router();
  router.get('/', (Request r) => dashboard(r));

  // Auth routes are registered before /<table>/ so the wildcard doesn't
  // swallow the literal "login" and "logout" path segments.
  if (auth != null) {
    // GET /login/  →  show login form
    router.get('/login/', (Request req) async {
      if (auth.isAuthenticated(req.headers)) return Response.found('$prefix/');
      return Response.ok(
        renderLoginPage(prefix: prefix, studioTitle: title),
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });

    // POST /login/  →  validate credentials, issue token cookie
    router.post('/login/', (Request req) async {
      final params = await bodyParams(req);
      final u = params['username']?.trim() ?? '';
      final p = params['password'] ?? '';

      final token = auth.authenticate(u, p);
      if (token != null) {
        return Response.found(
          '$prefix/',
          headers: {'set-cookie': auth.setCookieHeader(token, prefix: prefix)},
        );
      }

      return Response(
        401,
        body: renderLoginPage(
          prefix: prefix,
          studioTitle: title,
          errorMessage: 'Invalid username or password.',
        ),
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });

    // POST /logout/  →  revoke token and redirect to login
    router.post('/logout/', (Request req) async {
      final token = auth.currentToken(req.headers);
      if (token != null) auth.revokeToken(token);
      return Response.found(
        '$prefix/login/',
        headers: {'set-cookie': auth.clearCookieHeader(prefix: prefix)},
      );
    });
  }

  router.get('/<table>/', (Request r, String t) => listView(r, t));
  router.get('/<table>/add/', (Request r, String t) => addForm(r, t));
  router.post('/<table>/add/', (Request r, String t) => processAdd(r, t));
  router.get('/<table>/<pk>/change/',
      (Request r, String t, String pk) => changeForm(r, t, pk));
  router.post('/<table>/<pk>/change/',
      (Request r, String t, String pk) => processChange(r, t, pk));
  router.get('/<table>/<pk>/delete/',
      (Request r, String t, String pk) => deleteConfirm(r, t, pk));
  router.post('/<table>/<pk>/delete/',
      (Request r, String t, String pk) => processDelete(r, t, pk));
  router.post('/<table>/action/', (Request r, String t) => bulkAction(r, t));

  if (auth == null) return router.call;

  // Middleware: gate all non-login routes behind a valid session.
  return (Request req) async {
    final path = req.url.path;
    final isLoginPath = path == 'login' || path == 'login/';
    if (!isLoginPath && !auth.isAuthenticated(req.headers)) {
      return Response.found('$prefix/login/');
    }
    return router(req);
  };
}

// ── SQL helpers ──────────────────────────────────────────────────────────────

/// Tables estimated at this many rows or more show the estimate in the
/// sidebar instead of an exact count.
const _exactCountLimit = 100000;

String _buildInsertSql(String table, Map<String, Object?> values) {
  if (values.isEmpty) return 'INSERT INTO "$table" DEFAULT VALUES RETURNING *';
  final cols = values.keys.map((c) => '"$c"').join(', ');
  final placeholders =
      values.keys.indexed.map((e) => '\$${e.$1 + 1}').join(', ');
  return 'INSERT INTO "$table" ($cols) VALUES ($placeholders) RETURNING *';
}

String _buildUpdateSql(String table, String pk, Map<String, Object?> values) {
  final sets =
      values.keys.indexed.map((e) => '"${e.$2}" = \$${e.$1 + 1}').join(', ');
  final pkPlaceholder = '\$${values.length + 1}';
  return 'UPDATE "$table" SET $sets WHERE "$pk" = $pkPlaceholder RETURNING *';
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
