/// Base HTML layout for Gisila Studio pages.
library gisila_studio.ui.layout;

import '../model_admin.dart';
import 'theme.dart';

/// Wraps [body] in the full page shell: sidebar + topbar + content.
///
/// [topbarBreadcrumbs] renders the breadcrumb trail in the sticky topbar.
/// [topbarRight] renders action buttons in the topbar right slot.
/// [showLogout] controls whether a logout button appears in the sidebar footer.
String renderLayout({
  required String title,
  required String body,
  required String prefix,
  required List<ModelAdmin<dynamic>> admins,
  required Map<String, int> modelCounts,
  String? activeTable,
  List<(String, String?)> topbarBreadcrumbs = const [],
  String? topbarRight,
  String? studioTitle,
  String? flashMessage,
  bool flashIsError = false,
  bool showLogout = false,
}) {
  final sidebar = _renderSidebar(
    admins: admins,
    modelCounts: modelCounts,
    activeTable: activeTable,
    prefix: prefix,
    studioTitle: studioTitle,
    showLogout: showLogout,
  );

  final bcItems = [
    '<a href="$prefix/">Studio</a>',
    ...topbarBreadcrumbs.map((b) {
      final (label, url) = b;
      if (url != null) {
        return '<span class="sep">›</span><a href="$url">${_esc(label)}</a>';
      }
      return '<span class="sep">›</span><span class="crumb-current">${_esc(label)}</span>';
    }),
  ];
  if (topbarBreadcrumbs.isEmpty) {
    bcItems.clear();
    bcItems.add('<span class="crumb-current">Overview</span>');
  }
  final bcHtml = bcItems.join(' ');

  final flashHtml = flashMessage != null
      ? '''
        <div class="toast ${flashIsError ? 'toast-err' : 'toast-ok'}" id="studio-toast">
          <span class="toast-dot"></span>
          <span>${_esc(flashMessage)}</span>
          <button type="button" class="toast-dismiss" onclick="this.parentElement.remove()" aria-label="Dismiss">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
          </button>
        </div>'''
      : '';

  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${_esc(title)} — ${_esc(studioTitle ?? 'Gisila Studio')}</title>
  <style>$studioStyles</style>
</head>
<body>
  $sidebar

  <div class="main-wrap">
    <header class="topbar">
      <div class="breadcrumb">$bcHtml</div>
      ${topbarRight != null ? '<div class="topbar-actions">$topbarRight</div>' : ''}
    </header>
    <main class="content">
      $flashHtml
      $body
    </main>
  </div>

  <script>
    // Sidebar nav filter
    const navInput = document.getElementById('nav-filter');
    if (navInput) {
      navInput.addEventListener('input', () => {
        const q = navInput.value.toLowerCase().trim();
        document.querySelectorAll('.nav-group').forEach(g => {
          let visible = 0;
          g.querySelectorAll('.nav-item').forEach(a => {
            const match = !q || a.textContent.toLowerCase().includes(q);
            a.classList.toggle('nav-hidden', !match);
            if (match) visible++;
          });
          g.classList.toggle('nav-group-hidden', visible === 0 && q.length > 0);
        });
      });
    }

    // Select-all checkbox
    const selectAll = document.getElementById('select-all');
    if (selectAll) {
      selectAll.addEventListener('change', () => {
        document.querySelectorAll('.row-cb').forEach(cb => cb.checked = selectAll.checked);
        _updateSelBar();
      });
    }
    document.querySelectorAll('.row-cb').forEach(cb => {
      cb.addEventListener('change', () => {
        const all = document.querySelectorAll('.row-cb');
        const checked = document.querySelectorAll('.row-cb:checked');
        if (selectAll) {
          selectAll.indeterminate = checked.length > 0 && checked.length < all.length;
          selectAll.checked = checked.length === all.length && all.length > 0;
        }
        _updateSelBar();
      });
    });

    function _updateSelBar() {
      const bar = document.getElementById('sel-bar');
      if (!bar) return;
      const count = document.querySelectorAll('.row-cb:checked').length;
      bar.classList.toggle('visible', count > 0);
      const lbl = bar.querySelector('.sel-count');
      if (lbl) lbl.textContent = count + (count === 1 ? ' selected' : ' selected');
    }

    const clearSel = document.getElementById('clear-sel');
    if (clearSel) {
      clearSel.addEventListener('click', () => {
        document.querySelectorAll('.row-cb').forEach(cb => cb.checked = false);
        if (selectAll) { selectAll.checked = false; selectAll.indeterminate = false; }
        _updateSelBar();
      });
    }

    // Row click → navigate
    document.querySelectorAll('tbody tr[data-href]').forEach(tr => {
      tr.addEventListener('click', e => {
        if (e.target.closest('input, a, button')) return;
        window.location = tr.dataset.href;
      });
    });

    // Auto-dismiss toast
    const toast = document.getElementById('studio-toast');
    if (toast) setTimeout(() => { toast.style.transition = 'opacity .4s'; toast.style.opacity = '0'; setTimeout(() => toast.remove(), 400); }, 4000);
  </script>
</body>
</html>''';
}

/// Parses a `?_msg=` query param into a flash message.
(String? message, bool isError) parseFlashMessage(String? msg) {
  switch (msg) {
    case 'added':
      return ('Record created successfully.', false);
    case 'saved':
      return ('Changes saved.', false);
    case 'deleted':
      return ('Record deleted.', false);
    case 'action':
      return ('Action completed.', false);
    default:
      return (null, false);
  }
}

String _renderSidebar({
  required List<ModelAdmin<dynamic>> admins,
  required Map<String, int> modelCounts,
  required String prefix,
  String? studioTitle,
  String? activeTable,
  bool showLogout = false,
}) {
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

  final groupsHtml = order.map((g) {
    final items = groups[g]!.map((a) {
      final isActive = a.meta.tableName == activeTable;
      final count = modelCounts[a.meta.tableName];
      final badge =
          count != null ? '<span class="nav-badge">${_fmt(count)}</span>' : '';
      return '''
        <a class="nav-item${isActive ? ' active' : ''}" href="$prefix/${a.meta.tableName}/">
          ${_esc(a.displayNamePlural)}$badge
        </a>''';
    }).join('\n');
    return '''
      <div class="nav-group">
        <div class="nav-group-label">${_esc(g)}</div>
        $items
      </div>''';
  }).join('\n');

  final initial = (studioTitle ?? 'Gisila Studio').isNotEmpty
      ? (studioTitle ?? 'Gisila Studio')[0].toUpperCase()
      : 'G';

  return '''
  <aside class="sidebar">
    <a class="sidebar-logo" href="$prefix/">
      <div class="logo-mark">$initial</div>
      <div>
        <div class="logo-name">${_esc(studioTitle ?? 'Gisila Studio')}</div>
        <div class="logo-sub">Content studio</div>
      </div>
    </a>
    <div class="sidebar-search">
      <div class="sidebar-search-inner">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
        <input type="search" id="nav-filter" placeholder="Search collections…" autocomplete="off">
      </div>
    </div>
    <div class="sidebar-body">
      $groupsHtml
    </div>
    <div class="sidebar-footer">
      <a href="$prefix/">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="7" height="7" x="3" y="3" rx="1"/><rect width="7" height="7" x="14" y="3" rx="1"/><rect width="7" height="7" x="14" y="14" rx="1"/><rect width="7" height="7" x="3" y="14" rx="1"/></svg>
        Overview
      </a>
      ${showLogout ? '''
      <form method="post" action="$prefix/logout/" style="display:contents">
        <button type="submit" class="sidebar-logout">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
          Sign out
        </button>
      </form>''' : ''}
    </div>
  </aside>''';
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return n.toString();
}
