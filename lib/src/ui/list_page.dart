/// List view page for Gisila Studio.
library gisila_studio.ui.list_page;

import '../column_info.dart';
import '../model_admin.dart';
import 'layout.dart';

/// Renders the list view for a model.
String renderListPage({
  required ModelAdmin<dynamic> admin,
  required List<ModelAdmin<dynamic>> allAdmins,
  required List<Map<String, dynamic>> rows,
  required int totalCount,
  required int page,
  required int pageSize,
  required String? searchQuery,
  required List<ColumnInfo> columns,
  required Map<String, int> modelCounts,
  required String prefix,
  required String studioTitle,
  String? flashMessage,
  bool flashIsError = false,
  bool showLogout = false,
}) {
  final table = admin.meta.tableName;
  final displayCols = admin.effectiveListDisplay;
  final colInfoMap = {for (final c in columns) c.name: c};

  final headers =
      displayCols.map((col) => '<th>${_esc(_humanize(col))}</th>').join('\n');

  final rowsHtml = rows.isEmpty
      ? '''
        <tr>
          <td colspan="${displayCols.length + 1}" style="padding:0;cursor:default">
            <div class="empty-state">
              <div class="empty-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
              </div>
              <h3>${searchQuery != null ? 'No results found' : 'Nothing here yet'}</h3>
              <p>${searchQuery != null ? 'Try a different search for "${_esc(searchQuery)}".' : 'Add your first ${_esc(admin.displayName)} to populate this list.'}</p>
            </div>
          </td>
        </tr>'''
      : rows.map((row) {
          final pk = row[admin.meta.primaryKey];
          final pkStr = pk?.toString() ?? '';
          final href = '$prefix/$table/${Uri.encodeComponent(pkStr)}/change/';

          final cells = displayCols.map((col) {
            final value = row[col];
            final info = colInfoMap[col];
            final display = info?.display(value) ?? (value?.toString() ?? '—');
            final isFirst = col == displayCols.first;

            if (display == '✓')
              return '<td><span class="bool-yes">Yes</span></td>';
            if (display == '✗')
              return '<td><span class="bool-no">No</span></td>';

            if (isFirst) return '<td class="td-primary">${_esc(display)}</td>';

            // Render as monospace if it looks like an ID or date
            final info2 = colInfoMap[col];
            if (info2 != null &&
                (info2.dataType.contains('int') ||
                    info2.dataType.contains('date') ||
                    info2.dataType.contains('time') ||
                    info2.dataType.contains('uuid'))) {
              return '<td class="td-mono">${_esc(display)}</td>';
            }
            return '<td>${_esc(display)}</td>';
          }).join('\n');

          return '''
            <tr data-href="$href">
              <td class="cb-col"><input type="checkbox" class="row-cb" name="ids" value="${_esc(pkStr)}"></td>
              $cells
            </tr>''';
        }).join('\n');

  final searchVal = searchQuery != null ? _esc(searchQuery) : '';
  final searchBar = admin.searchFields.isNotEmpty
      ? '''
        <div class="table-toolbar">
          <form method="get" action="$prefix/$table/" style="display:contents">
            <div class="search-wrap">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
              <input type="text" name="q" placeholder="Search ${_esc(admin.displayNamePlural)}…" value="$searchVal">
            </div>
            ${searchQuery != null ? '<a class="btn btn-ghost btn-sm" href="$prefix/$table/">Clear</a>' : ''}
          </form>
        </div>'''
      : '';

  final totalPages =
      (totalCount / pageSize).ceil().clamp(1, double.infinity).toInt();
  final rangeStart = rows.isEmpty ? 0 : (page - 1) * pageSize + 1;
  final rangeEnd = (page - 1) * pageSize + rows.length;

  String pgLink(int p, String label,
      {bool disabled = false, bool current = false}) {
    if (disabled) return '<span class="disabled">$label</span>';
    if (current) return '<span class="current">$label</span>';
    final q = searchQuery != null
        ? '&q=${Uri.encodeQueryComponent(searchQuery)}'
        : '';
    return '<a href="$prefix/$table/?page=$p$q">$label</a>';
  }

  final pgLinks = StringBuffer();
  pgLinks.write(pgLink(page - 1, '‹', disabled: page <= 1));
  final first = (page - 2).clamp(1, totalPages);
  final last = (page + 2).clamp(1, totalPages);
  if (first > 1) {
    pgLinks.write(pgLink(1, '1'));
    if (first > 2) pgLinks.write('<span>…</span>');
  }
  for (var p = first; p <= last; p++) {
    pgLinks.write(pgLink(p, '$p', current: p == page));
  }
  if (last < totalPages) {
    if (last < totalPages - 1) pgLinks.write('<span>…</span>');
    pgLinks.write(pgLink(totalPages, '$totalPages'));
  }
  pgLinks.write(pgLink(page + 1, '›', disabled: page >= totalPages));

  final subtitle = searchQuery != null
      ? '${_fmt(totalCount)} results for "${_esc(searchQuery)}"'
      : '${_fmt(totalCount)} records';

  final addBtn = '''
    <a class="btn btn-primary btn-sm" href="$prefix/$table/add/">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
      New ${_esc(admin.displayName)}
    </a>''';

  final body = '''
    <div class="page-hdr">
      <div class="page-title">${_esc(admin.displayNamePlural)}</div>
      <div class="page-meta">$subtitle</div>
    </div>

    <form id="list-form" method="post" action="$prefix/$table/action/">
      <div class="sel-bar" id="sel-bar">
        <span class="sel-count">0 selected</span>
        <div class="sel-sep"></div>
        <button type="button" class="btn btn-ghost btn-sm" id="clear-sel">Clear</button>
        <button type="submit" class="btn btn-danger btn-sm" name="action" value="delete"
                onclick="return confirm('Delete selected records? This cannot be undone.')">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>
          Delete
        </button>
      </div>

      <div class="table-card">
        $searchBar
        <div style="overflow-x:auto">
          <table>
            <thead>
              <tr>
                <th class="cb-col">
                  <input type="checkbox" id="select-all" title="Select all">
                </th>
                $headers
              </tr>
            </thead>
            <tbody>$rowsHtml</tbody>
          </table>
        </div>
        ${rows.isNotEmpty ? '''
        <div class="pagination">
          <span class="pagination-info">$rangeStart–$rangeEnd of ${_fmt(totalCount)}</span>
          <div class="pagination-links">$pgLinks</div>
        </div>''' : ''}
      </div>
    </form>''';

  return renderLayout(
    title: admin.displayNamePlural,
    body: body,
    prefix: prefix,
    admins: allAdmins,
    modelCounts: modelCounts,
    activeTable: table,
    studioTitle: studioTitle,
    topbarBreadcrumbs: [(admin.displayNamePlural, null)],
    topbarRight: addBtn,
    flashMessage: flashMessage,
    flashIsError: flashIsError,
    showLogout: showLogout,
  );
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _humanize(String snake) => snake
    .split('_')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return n.toString();
}
