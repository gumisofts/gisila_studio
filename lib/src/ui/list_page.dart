/// List view page for Gisila Studio.
library gisila_studio.ui.list_page;

import '../column_info.dart';
import '../model_admin.dart';
import 'icons.dart';
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
          <td colspan="${displayCols.length + 1}" style="padding:0;cursor:default;max-width:none;white-space:normal">
            <div class="empty-state">
              ${icon(searchQuery != null ? 'search' : 'data-table', size: 64)}
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
              return '<td><span class="tag tag-green">Yes</span></td>';
            if (display == '✗')
              return '<td><span class="tag tag-gray">No</span></td>';

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
              <td class="cb-col"><input type="checkbox" class="row-cb" form="list-form" name="ids" value="${_esc(pkStr)}" aria-label="Select row"></td>
              $cells
            </tr>''';
        }).join('\n');

  final searchVal = searchQuery != null ? _esc(searchQuery) : '';
  final search = admin.searchFields.isNotEmpty
      ? '''
            <form method="get" action="$prefix/$table/" role="search">
              <div class="toolbar-search">
                ${icon('search')}
                <input type="search" name="q" placeholder="Search ${_esc(admin.displayNamePlural.toLowerCase())}" value="$searchVal" aria-label="Search">
                ${searchQuery != null ? '<a class="toolbar-search-clear" href="$prefix/$table/" aria-label="Clear search">${icon('close')}</a>' : ''}
              </div>
            </form>'''
      : '';

  final totalPages =
      (totalCount / pageSize).ceil().clamp(1, double.infinity).toInt();
  final rangeStart = rows.isEmpty ? 0 : (page - 1) * pageSize + 1;
  final rangeEnd = (page - 1) * pageSize + rows.length;

  String pageHref(int p) {
    final q = searchQuery != null
        ? '&q=${Uri.encodeQueryComponent(searchQuery)}'
        : '';
    return '$prefix/$table/?page=$p$q';
  }

  String pgLink(int p) => p == page
      ? '<span class="current" aria-current="page">$p</span>'
      : '<a href="${pageHref(p)}" aria-label="Page $p">$p</a>';

  final pgLinks = StringBuffer();
  final first = (page - 2).clamp(1, totalPages);
  final last = (page + 2).clamp(1, totalPages);
  if (first > 1) {
    pgLinks.write(pgLink(1));
    if (first > 2) pgLinks.write('<span>…</span>');
  }
  for (var p = first; p <= last; p++) {
    pgLinks.write(pgLink(p));
  }
  if (last < totalPages) {
    if (last < totalPages - 1) pgLinks.write('<span>…</span>');
    pgLinks.write(pgLink(totalPages));
  }

  String step(int p, String iconName, String label, bool disabled) => disabled
      ? '<span class="pagination-step disabled" aria-disabled="true">${icon(iconName)}</span>'
      : '<a class="pagination-step" href="${pageHref(p)}" aria-label="$label">${icon(iconName)}</a>';

  final subtitle = searchQuery != null
      ? '${_fmt(totalCount)} results for "${_esc(searchQuery)}"'
      : '${_fmt(totalCount)} records';

  final body = '''
    <form id="list-form" method="post" action="$prefix/$table/action/"></form>
    <div class="data-table-container">
      <div class="data-table-header">
        <h1 class="data-table-title">${_esc(admin.displayNamePlural)}</h1>
        <p class="data-table-desc">$subtitle</p>
      </div>

      <section class="table-toolbar" aria-label="Table toolbar">
        <div class="batch-actions" id="sel-bar" aria-hidden="true">
          <span class="batch-summary sel-count">0 items selected</span>
          <button type="submit" form="list-form" class="btn btn-primary" name="action" value="delete"
                  onclick="return confirm('Delete the selected records? This cannot be undone.')">
            Delete ${icon('trash')}
          </button>
          <span class="batch-sep"></span>
          <button type="button" class="btn btn-primary" id="clear-sel">Cancel</button>
        </div>
        <div class="toolbar-content">
          $search
          <a class="btn btn-primary" href="$prefix/$table/add/">
            <span class="btn-label">Add ${_esc(admin.displayName.toLowerCase())}</span>${icon('add')}
          </a>
        </div>
      </section>

      <div class="table-scroll">
        <table aria-label="${_esc(admin.displayNamePlural)}">
          <thead>
            <tr>
              <th class="cb-col">
                <input type="checkbox" id="select-all" aria-label="Select all rows">
              </th>
              $headers
            </tr>
          </thead>
          <tbody>$rowsHtml</tbody>
        </table>
      </div>
      ${rows.isNotEmpty ? '''
      <div class="pagination">
        <span class="pagination-info">$rangeStart–$rangeEnd of ${_fmt(totalCount)} items</span>
        <div class="pagination-right">
          <nav class="pagination-pages" aria-label="Pages">$pgLinks</nav>
          ${step(page - 1, 'chevron-left', 'Previous page', page <= 1)}
          ${step(page + 1, 'chevron-right', 'Next page', page >= totalPages)}
        </div>
      </div>''' : ''}
    </div>''';

  return renderLayout(
    title: admin.displayNamePlural,
    body: body,
    prefix: prefix,
    admins: allAdmins,
    modelCounts: modelCounts,
    activeTable: table,
    studioTitle: studioTitle,
    topbarBreadcrumbs: [(admin.displayNamePlural, null)],
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
