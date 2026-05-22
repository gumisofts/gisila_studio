/// Dashboard page for Gisila Studio.
library gisila_studio.ui.dashboard;

import '../model_admin.dart';
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
          <div class="page-title">Overview</div>
        </div>
        <div class="table-card">
          <div class="empty-state">
            <div class="empty-icon">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect width="7" height="7" x="3" y="3" rx="1"/><rect width="7" height="7" x="14" y="3" rx="1"/><rect width="7" height="7" x="14" y="14" rx="1"/><rect width="7" height="7" x="3" y="14" rx="1"/></svg>
            </div>
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
      final initial =
          a.displayName.isNotEmpty ? a.displayName[0].toUpperCase() : '?';
      return '''
        <a class="model-tile" href="$prefix/${a.meta.tableName}/">
          <div class="model-tile-ic">$initial</div>
          <div>
            <div class="model-tile-name">${_esc(a.displayNamePlural)}</div>
            <div class="model-tile-count">${_fmt(count)} records</div>
          </div>
        </a>''';
    }).join('\n');
    return '''
      <div class="section-lbl">${_esc(g)}</div>
      <div class="model-grid">$tiles</div>''';
  }).join('\n');

  final body = '''
    <div class="dash-hero">
      <h1>Welcome back</h1>
      <p>Your content at a glance. Select a collection from the sidebar to browse and manage records.</p>
      <div class="dash-kpis">
        <div><div class="kpi-val">${admins.length}</div><div class="kpi-lbl">Collections</div></div>
        <div><div class="kpi-val">${_fmt(totalRecords)}</div><div class="kpi-lbl">Total records</div></div>
      </div>
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
