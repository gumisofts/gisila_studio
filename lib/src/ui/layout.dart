/// Base HTML layout for Gisila Studio pages, built on the Carbon UI shell.
library gisila_studio.ui.layout;

import '../model_admin.dart';
import 'icons.dart';
import 'theme.dart';

/// Wraps [body] in the full page shell: header + side nav + content.
///
/// [topbarBreadcrumbs] renders the breadcrumb trail above the page.
/// [topbarRight] renders action buttons at the right of the breadcrumb row.
/// [showLogout] controls whether a sign-out action appears in the header.
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
  );

  final crumbs = topbarBreadcrumbs.isEmpty
      ? ''
      : [
          '<li class="breadcrumb-item"><a href="$prefix/">Overview</a></li>',
          ...topbarBreadcrumbs.map((b) {
            final (label, url) = b;
            return url != null
                ? '<li class="breadcrumb-item"><a href="$url">${_esc(label)}</a></li>'
                : '<li class="breadcrumb-item" aria-current="page">${_esc(label)}</li>';
          }),
        ].join();
  final breadcrumbRow = crumbs.isEmpty && topbarRight == null
      ? ''
      : '''
      <div class="breadcrumb-row">
        <nav aria-label="Breadcrumb"><ol class="breadcrumb">$crumbs</ol></nav>
        ${topbarRight != null ? '<div class="breadcrumb-actions">$topbarRight</div>' : ''}
      </div>''';

  final flashHtml = flashMessage != null
      ? '''
        <div class="notification ${flashIsError ? 'notification-error' : 'notification-success'}" id="studio-toast" role="status">
          ${icon(flashIsError ? 'error-filled' : 'checkmark-filled', size: 20)}
          <div><span class="notification-title">${flashIsError ? 'Error' : 'Success'}</span>${_esc(flashMessage)}</div>
          <button type="button" class="notification-close" onclick="this.parentElement.remove()" aria-label="Close notification">
            ${icon('close')}
          </button>
        </div>'''
      : '';

  final name = studioTitle ?? 'Gisila Studio';

  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${_esc(title)} — ${_esc(name)}</title>
  <style>$studioStyles</style>
</head>
<body>
  ${renderHeader(prefix: prefix, studioTitle: name, showLogout: showLogout, withMenu: true)}

  $sidebar
  <div class="side-nav-overlay" id="side-nav-overlay"></div>

  <main class="content">
    $breadcrumbRow
    $flashHtml
    $body
  </main>

  <script>
    // Side nav drawer on small screens
    const sideNav = document.getElementById('side-nav');
    const menuToggle = document.getElementById('menu-toggle');
    function _setNav(open) {
      sideNav.classList.toggle('expanded', open);
      menuToggle.setAttribute('aria-expanded', open);
    }
    menuToggle.addEventListener('click', () => _setNav(!sideNav.classList.contains('expanded')));
    document.getElementById('side-nav-overlay').addEventListener('click', () => _setNav(false));

    // Side nav filter
    const navInput = document.getElementById('nav-filter');
    if (navInput) {
      navInput.addEventListener('input', () => {
        const q = navInput.value.toLowerCase().trim();
        document.querySelectorAll('.side-nav-group').forEach(g => {
          let visible = 0;
          g.querySelectorAll('.side-nav-link').forEach(a => {
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
      document.querySelectorAll('.row-cb').forEach(cb =>
        cb.closest('tr').classList.toggle('selected', cb.checked));
      const bar = document.getElementById('sel-bar');
      if (!bar) return;
      const count = document.querySelectorAll('.row-cb:checked').length;
      bar.classList.toggle('visible', count > 0);
      bar.setAttribute('aria-hidden', count === 0);
      const lbl = bar.querySelector('.sel-count');
      if (lbl) lbl.textContent = count + (count === 1 ? ' item selected' : ' items selected');
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

    // Auto-dismiss success notifications
    const toast = document.querySelector('.notification-success');
    if (toast) setTimeout(() => { toast.style.transition = 'opacity .24s'; toast.style.opacity = '0'; setTimeout(() => toast.remove(), 240); }, 5000);
  </script>
</body>
</html>''';
}

/// The Carbon UI shell header. [withMenu] adds the hamburger that opens the
/// side nav on small screens.
String renderHeader({
  required String prefix,
  required String studioTitle,
  bool showLogout = false,
  bool withMenu = false,
}) {
  final name = studioTitle.startsWith('Gisila ')
      ? '<span class="header-name-prefix">Gisila</span>'
          '${_esc(studioTitle.substring(7))}'
      : _esc(studioTitle);
  final menu = withMenu
      ? '''
    <button type="button" class="header-menu-btn" id="menu-toggle" aria-label="Open menu" aria-controls="side-nav" aria-expanded="false">
      ${icon('menu', size: 20)}
    </button>'''
      : '';
  final logout = showLogout
      ? '''
    <div class="header-global">
      <form method="post" action="$prefix/logout/" style="display:contents">
        <button type="submit" class="header-action" aria-label="Sign out" title="Sign out">${icon('logout', size: 20)}</button>
      </form>
    </div>'''
      : '';
  return '''
  <header class="shell-header" aria-label="${_esc(studioTitle)}">$menu
    <a class="header-name" href="$prefix/">$name</a>$logout
  </header>''';
}

/// Parses a `?_msg=` query param into a flash message.
(String? message, bool isError) parseFlashMessage(String? msg) {
  switch (msg) {
    case 'added':
      return ('Record created.', false);
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
  String? activeTable,
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
      final badge = count != null
          ? '<span class="side-nav-count">${_fmt(count)}</span>'
          : '';
      return '''
        <a class="side-nav-link${isActive ? ' active' : ''}" href="$prefix/${a.meta.tableName}/"${isActive ? ' aria-current="page"' : ''}>
          <span>${_esc(a.displayNamePlural)}</span>$badge
        </a>''';
    }).join('\n');
    return '''
      <div class="side-nav-group">
        <div class="side-nav-group-label">${_esc(g)}</div>
        $items
      </div>''';
  }).join('\n');

  return '''
  <nav class="side-nav" id="side-nav" aria-label="Collections">
    <div class="side-nav-search">
      <div class="toolbar-search">
        ${icon('search')}
        <input type="search" id="nav-filter" class="side-nav-filter" placeholder="Filter collections" autocomplete="off" aria-label="Filter collections">
      </div>
    </div>
    <div class="side-nav-items">
      $groupsHtml
    </div>
    <div class="side-nav-footer">
      <a class="side-nav-link${activeTable == null ? ' active' : ''}" href="$prefix/">
        ${icon('dashboard')}<span>Overview</span>
      </a>
    </div>
  </nav>''';
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
