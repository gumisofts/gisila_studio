/// Dashboard page for Gisila Studio.
library gisila_studio.ui.dashboard;

import '../model_admin.dart';
import 'icons.dart';
import 'layout.dart';

/// Renders the dashboard overview.
String renderDashboard({
  required List<ModelAdmin<dynamic>> admins,
  required Map<String, int> counts,
  required String prefix,
  required String studioTitle,
  bool showLogout = false,
}) {
  if (admins.isEmpty) {
    return renderLayout(
      title: 'Overview',
      body: '''
        <div class="page-hdr">
          <h1 class="page-title">Overview</h1>
        </div>
        <div class="data-table-container">
          <div class="empty-state">
            ${icon('data-table', size: 64)}
            <h3>No collections registered</h3>
            <p>Call <code>studio.register()</code> to add models.</p>
          </div>
        </div>''',
      prefix: prefix,
      admins: admins,
      modelCounts: counts,
      studioTitle: studioTitle,
      showLogout: showLogout,
    );
  }

  final totalRecords = counts.values.fold<int>(0, (s, c) => s + c);

  // Build groups
  final groups = <String, List<ModelAdmin<dynamic>>>{};
  for (final a in admins) {
    groups.putIfAbsent(a.group ?? 'General', () => []).add(a);
  }
  const preferred = [
    'Users & Auth',
    'Catalog',
    'Business',
    'Products',
    'Commerce',
    'Social',
    'Moderation',
    'Platform',
    'General',
  ];
  final order = [
    ...preferred.where(groups.containsKey),
    ...groups.keys.where((k) => !preferred.contains(k)),
  ];

  final sections = order.map((g) {
    final tiles = groups[g]!.map((a) {
      final count = counts[a.meta.tableName] ?? 0;
      return '''
        <a class="tile-clickable" href="$prefix/${a.meta.tableName}/">
          <div>
            <div class="tile-name">${_esc(a.displayNamePlural)}</div>
            <div class="tile-count">${_fmt(count)} ${count == 1 ? 'record' : 'records'}</div>
          </div>
          ${icon('arrow-right')}
        </a>''';
    }).join('\n');
    return '''
      <h2 class="section-lbl">${_esc(g)}</h2>
      <div class="tile-grid">$tiles</div>''';
  }).join('\n');

  final body = '''
    <div class="page-hdr">
      <h1 class="page-title">Overview</h1>
      <p class="page-meta">Choose a collection to browse and manage its records.</p>
    </div>
    <div class="kpi-row">
      <div class="kpi"><div class="kpi-lbl">Collections</div><div class="kpi-val">${admins.length}</div></div>
      <div class="kpi"><div class="kpi-lbl">Total records</div><div class="kpi-val">${_fmt(totalRecords)}</div></div>
    </div>
    $sections''';

  return renderLayout(
    title: 'Overview',
    body: body,
    prefix: prefix,
    admins: admins,
    modelCounts: counts,
    studioTitle: studioTitle,
    topbarBreadcrumbs: [],
    showLogout: showLogout,
  );
}

String _esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return n.toString();
}
