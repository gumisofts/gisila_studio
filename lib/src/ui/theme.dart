/// CSS stylesheet for Gisila Studio, following the IBM Carbon Design System
/// (v11): Carbon colour tokens with the g10 theme in light mode and g100 in
/// dark mode, IBM Plex type, the UI shell, and Carbon's data table, form,
/// button, tag, tile and notification patterns.
library gisila_studio.ui.theme;

const String studioStyles = r'''
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=IBM+Plex+Sans:wght@300;400;600&display=swap');

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

/* ── Tokens: g10 ─────────────────────────────────────────────── */

:root {
  --header-h: 48px;
  --side-nav-w: 256px;

  --background:          #f4f4f4;
  --background-hover:    rgba(141,141,141,.12);
  --background-selected: rgba(141,141,141,.2);
  --layer-01:            #ffffff;
  --layer-02:            #f4f4f4;
  --layer-hover-01:      #e8e8e8;
  --layer-selected-01:   #e0e0e0;
  --layer-accent-01:     #e0e0e0;
  --field-01:            #ffffff;
  --field-02:            #f4f4f4;
  --field-hover-02:      #e8e8e8;
  --border-subtle-01:    #e0e0e0;
  --border-strong-01:    #8d8d8d;
  --text-primary:        #161616;
  --text-secondary:      #525252;
  --text-helper:         #6f6f6f;
  --text-placeholder:    #a8a8a8;
  --text-on-color:       #ffffff;
  --text-error:          #da1e28;
  --icon-secondary:      #525252;
  --link-primary:        #0f62fe;
  --link-primary-hover:  #0043ce;
  --focus:               #0f62fe;
  --focus-inset:         #ffffff;
  --interactive:         #0f62fe;
  --border-interactive:  #0f62fe;

  --button-primary:          #0f62fe;
  --button-primary-hover:    #0050e6;
  --button-primary-active:   #002d9c;
  --button-secondary:        #393939;
  --button-secondary-hover:  #474747;
  --button-secondary-active: #6f6f6f;
  --button-danger:           #da1e28;
  --button-danger-hover:     #b81921;
  --button-danger-active:    #750e13;
  --button-ghost-hover:      #e8e8e8;

  --support-error:   #da1e28;
  --support-success: #24a148;
  --support-warning: #f1c21b;
  --notification-error-bg:   #fff1f1;
  --notification-success-bg: #defbe6;

  --tag-green-bg: #a7f0ba; --tag-green-fg: #0e6027;
  --tag-gray-bg:  #e0e0e0; --tag-gray-fg:  #161616;

  --shell-bg:       #161616;
  --shell-border:   #393939;
  --shell-text:     #c6c6c6;
  --shell-text-hi:  #f4f4f4;
  --shell-hover:    #2c2c2c;

  --font: 'IBM Plex Sans', 'Helvetica Neue', Arial, sans-serif;
  --mono: 'IBM Plex Mono', Menlo, 'DejaVu Sans Mono', Courier, monospace;
  --ease: cubic-bezier(.2, 0, .38, .9);
}

/* ── Tokens: g100 ────────────────────────────────────────────── */

@media (prefers-color-scheme: dark) {
  :root {
    --background:          #161616;
    --background-hover:    rgba(141,141,141,.16);
    --background-selected: rgba(141,141,141,.24);
    --layer-01:            #262626;
    --layer-02:            #393939;
    --layer-hover-01:      #333333;
    --layer-selected-01:   #393939;
    --layer-accent-01:     #393939;
    --field-01:            #262626;
    --field-02:            #393939;
    --field-hover-02:      #474747;
    --border-subtle-01:    #393939;
    --border-strong-01:    #6f6f6f;
    --text-primary:        #f4f4f4;
    --text-secondary:      #c6c6c6;
    --text-helper:         #a8a8a8;
    --text-placeholder:    #6f6f6f;
    --text-error:          #ff8389;
    --icon-secondary:      #c6c6c6;
    --link-primary:        #78a9ff;
    --link-primary-hover:  #a6c8ff;
    --focus:               #ffffff;
    --focus-inset:         #161616;
    --interactive:         #4589ff;
    --border-interactive:  #4589ff;
    --button-secondary:        #6f6f6f;
    --button-secondary-hover:  #5e5e5e;
    --button-secondary-active: #393939;
    --button-ghost-hover:      #333333;
    --support-error:   #fa4d56;
    --support-success: #42be65;
    --notification-error-bg:   #262626;
    --notification-success-bg: #262626;
    --tag-green-bg: #044317; --tag-green-fg: #6fdc8c;
    --tag-gray-bg:  #393939; --tag-gray-fg:  #e0e0e0;
    color-scheme: dark;
  }
}

body {
  font-family: var(--font);
  font-size: 14px;
  line-height: 1.28572;
  letter-spacing: .16px;
  color: var(--text-primary);
  background: var(--background);
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

a { color: var(--link-primary); }
code { font-family: var(--mono); font-size: 12px; }
.cds-icon { flex-shrink: 0; }

:focus-visible { outline: 2px solid var(--focus); outline-offset: -2px; }

/* ── UI shell: header ────────────────────────────────────────── */

.shell-header {
  position: fixed; top: 0; left: 0; right: 0; z-index: 8000;
  height: var(--header-h);
  display: flex; align-items: center;
  background: var(--shell-bg);
  border-bottom: 1px solid var(--shell-border);
}

.header-menu-btn {
  display: none;
  width: 48px; height: 48px;
  align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer;
  color: var(--shell-text-hi);
}
.header-menu-btn:hover { background: var(--shell-hover); }

.header-name {
  display: flex; align-items: center; height: 100%;
  padding: 0 32px 0 16px;
  font-size: 14px; font-weight: 600; letter-spacing: .1px;
  color: var(--shell-text-hi); text-decoration: none;
  white-space: nowrap; user-select: none;
}
.header-name-prefix { font-weight: 400; margin-right: .25rem; }

.header-global { margin-left: auto; display: flex; height: 100%; }
.header-action {
  display: inline-flex; align-items: center; justify-content: center;
  width: 48px; height: 48px;
  background: none; border: none; cursor: pointer;
  color: var(--shell-text-hi);
}
.header-action:hover { background: var(--shell-hover); }

/* ── UI shell: side nav ──────────────────────────────────────── */

.side-nav {
  position: fixed; top: var(--header-h); left: 0; bottom: 0; z-index: 7000;
  width: var(--side-nav-w);
  display: flex; flex-direction: column;
  background: var(--layer-01);
  border-right: 1px solid var(--border-subtle-01);
  transition: transform .11s var(--ease);
}

.side-nav-search { padding: 16px 16px 8px; flex-shrink: 0; }

.side-nav-filter { height: 32px !important; padding-right: 16px !important; }
.side-nav-search .toolbar-search input { background: var(--field-02); }

.side-nav-items { flex: 1; overflow-y: auto; padding-bottom: 16px; }

.side-nav-group { padding-top: 16px; }
.side-nav-group-label {
  font-size: 12px; line-height: 1.33333; letter-spacing: .32px;
  font-weight: 600; color: var(--text-secondary);
  padding: 0 16px 8px;
}

.side-nav-link {
  position: relative;
  display: flex; align-items: center; justify-content: space-between; gap: 8px;
  min-height: 32px; padding: 0 16px;
  font-size: 14px; font-weight: 600; line-height: 1.28572; letter-spacing: .16px;
  color: var(--text-secondary); text-decoration: none;
  transition: background-color .11s var(--ease), color .11s var(--ease);
}
.side-nav-link span:first-child { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.side-nav-link:hover { background: var(--background-hover); color: var(--text-primary); }
.side-nav-link.active {
  background: var(--background-selected); color: var(--text-primary);
}
.side-nav-link.active::before {
  content: ''; position: absolute; left: 0; top: 0; bottom: 0;
  width: 3px; background: var(--border-interactive);
}
.side-nav-count {
  font-size: 12px; font-weight: 400; letter-spacing: .32px;
  color: var(--text-helper);
}
.side-nav-link.nav-hidden, .side-nav-group.nav-group-hidden { display: none; }

.side-nav-footer {
  flex-shrink: 0;
  border-top: 1px solid var(--border-subtle-01);
  padding: 8px 0;
}
.side-nav-footer .side-nav-link { justify-content: flex-start; gap: 12px; }
.side-nav-footer .cds-icon { fill: var(--icon-secondary); }

.side-nav-overlay { display: none; }

/* ── Content ─────────────────────────────────────────────────── */

.content {
  margin-left: var(--side-nav-w);
  padding: calc(var(--header-h) + 24px) 32px 64px;
  min-height: 100vh;
}

.breadcrumb-row {
  display: flex; align-items: center; justify-content: space-between; gap: 16px;
  margin-bottom: 8px; min-height: 18px;
}
.breadcrumb { display: flex; flex-wrap: wrap; align-items: center; list-style: none; }
.breadcrumb-item {
  display: flex; align-items: center;
  font-size: 14px; line-height: 1.28572; letter-spacing: .16px;
  color: var(--text-primary);
}
.breadcrumb-item::after {
  content: '/'; margin: 0 8px; color: var(--text-primary);
}
.breadcrumb-item:last-child::after { content: none; }
.breadcrumb-item a { color: var(--link-primary); text-decoration: none; }
.breadcrumb-item a:hover { color: var(--link-primary-hover); text-decoration: underline; }
.breadcrumb-actions { display: flex; gap: 1px; }

/* ── Page header ─────────────────────────────────────────────── */

.page-hdr { margin-bottom: 32px; }
.page-title {
  font-size: 28px; font-weight: 400; line-height: 1.28572; letter-spacing: 0;
  color: var(--text-primary);
}
.page-meta {
  font-size: 14px; line-height: 1.42857; letter-spacing: .16px;
  color: var(--text-secondary); margin-top: 8px; max-width: 640px;
}

/* ── Buttons ─────────────────────────────────────────────────── */

.btn {
  position: relative;
  display: inline-flex; align-items: center; justify-content: space-between;
  gap: 32px;
  min-height: 48px; max-width: 20rem;
  padding: 0 15px;
  border: 1px solid transparent; border-radius: 0;
  font-family: var(--font); font-size: 14px; font-weight: 400;
  line-height: 1.28572; letter-spacing: .16px;
  text-align: left; text-decoration: none; white-space: nowrap;
  cursor: pointer;
  transition: background .07s var(--ease), box-shadow .07s var(--ease),
              border-color .07s var(--ease), color .07s var(--ease);
}
.btn:not(.btn-icon-only) { padding-right: 15px; min-width: 9rem; }
.btn:focus-visible {
  outline: none;
  border-color: var(--focus);
  box-shadow: inset 0 0 0 1px var(--focus), inset 0 0 0 2px var(--focus-inset);
}

.btn-primary { background: var(--button-primary); color: var(--text-on-color); }
.btn-primary:hover { background: var(--button-primary-hover); }
.btn-primary:active { background: var(--button-primary-active); }

.btn-secondary { background: var(--button-secondary); color: var(--text-on-color); }
.btn-secondary:hover { background: var(--button-secondary-hover); }
.btn-secondary:active { background: var(--button-secondary-active); }

.btn-ghost {
  background: transparent; color: var(--link-primary);
  min-width: 0 !important; gap: 8px;
}
.btn-ghost:hover { background: var(--button-ghost-hover); color: var(--link-primary-hover); }

.btn-danger { background: var(--button-danger); color: var(--text-on-color); }
.btn-danger:hover { background: var(--button-danger-hover); }
.btn-danger:active { background: var(--button-danger-active); }

.btn-danger-ghost {
  background: transparent; color: var(--support-error);
  min-width: 0 !important; gap: 8px;
}
.btn-danger-ghost:hover { background: var(--button-danger); color: var(--text-on-color); }

.btn-md { min-height: 40px; }
.btn-sm { min-height: 32px; }

.btn-icon-only {
  width: 48px; padding: 0; justify-content: center; gap: 0;
}

/* Button set: buttons share the row edge to edge, as in Carbon modals. */
.btn-set { display: flex; }
.btn-set .btn { flex: 1 1 50%; max-width: none; height: 64px; align-items: flex-start; padding-top: 14px; }

/* ── Inline notification ─────────────────────────────────────── */

.notification {
  position: relative;
  display: flex; align-items: flex-start; gap: 16px;
  min-height: 48px; max-width: 48rem;
  padding: 15px 48px 15px 13px;
  margin-bottom: 24px;
  border: 1px solid; border-left-width: 3px;
  color: var(--text-primary);
  font-size: 14px; line-height: 1.28572; letter-spacing: .16px;
}
.notification-title { font-weight: 600; margin-right: 4px; }
.notification-success {
  background: var(--notification-success-bg);
  border-color: rgba(36,161,72,.5); border-left-color: var(--support-success);
}
.notification-success .cds-icon { fill: var(--support-success); }
.notification-error {
  background: var(--notification-error-bg);
  border-color: rgba(218,30,40,.5); border-left-color: var(--support-error);
}
.notification-error .cds-icon { fill: var(--support-error); }
.notification-close {
  position: absolute; top: 0; right: 0;
  width: 48px; height: 48px;
  display: flex; align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer;
}
.notification-close .cds-icon { fill: var(--text-primary) !important; }

/* ── Data table ──────────────────────────────────────────────── */

.data-table-container { background: var(--layer-01); }

.data-table-header { padding: 16px 16px 24px; }
.data-table-title { font-size: 20px; font-weight: 400; line-height: 1.4; }
.data-table-desc {
  font-size: 14px; line-height: 1.28572; letter-spacing: .16px;
  color: var(--text-secondary); margin-top: 2px;
}

.table-toolbar {
  position: relative;
  display: flex; height: 48px;
  background: var(--layer-01);
}
.toolbar-content { display: flex; flex: 1; justify-content: flex-end; }
.toolbar-content form { display: contents; }

.toolbar-search {
  position: relative; flex: 1; display: flex; align-items: center;
}
.toolbar-search .cds-icon {
  position: absolute; left: 16px; fill: var(--icon-secondary); pointer-events: none;
}
.toolbar-search input {
  width: 100%; height: 48px;
  padding: 0 48px;
  background: var(--field-02);
  border: none; border-bottom: 1px solid transparent;
  font-family: var(--font); font-size: 14px; letter-spacing: .16px;
  color: var(--text-primary); outline: 2px solid transparent; outline-offset: -2px;
}
.toolbar-search input::placeholder { color: var(--text-placeholder); }
.toolbar-search input:hover { background: var(--field-hover-02); }
.toolbar-search input:focus { outline-color: var(--focus); }
.toolbar-search-clear {
  position: absolute; right: 0; top: 0;
  width: 48px; height: 48px;
  display: flex; align-items: center; justify-content: center;
  color: var(--icon-secondary);
}
.toolbar-search-clear:hover { background: var(--field-hover-02); }
.toolbar-search-clear .cds-icon { position: static; }

/* Batch actions slide over the toolbar when rows are selected. */
.batch-actions {
  position: absolute; inset: 0;
  display: flex; align-items: center;
  background: var(--button-primary); color: var(--text-on-color);
  transform: translate3d(0, 48px, 0); clip-path: polygon(0 0, 100% 0, 100% 0, 0 0);
  pointer-events: none;
  transition: transform .11s var(--ease), clip-path .11s var(--ease);
}
.batch-actions.visible {
  transform: translate3d(0, 0, 0); clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%);
  pointer-events: all;
}
.batch-summary { flex: 1; padding-left: 16px; font-size: 14px; letter-spacing: .16px; }
.batch-actions .btn {
  min-width: 0; gap: 8px; border: none;
  background: var(--button-primary); color: var(--text-on-color);
}
.batch-actions .btn:hover { background: var(--button-primary-hover); }
.batch-actions .btn .cds-icon { fill: currentColor; }
.batch-sep { width: 1px; height: 16px; background: var(--text-on-color); opacity: .5; }

.table-scroll { overflow-x: auto; }

table { width: 100%; border-collapse: collapse; border-spacing: 0; }

thead th {
  height: 48px; padding: 0 16px;
  background: var(--layer-accent-01);
  font-size: 14px; font-weight: 600; line-height: 1.28572; letter-spacing: .16px;
  color: var(--text-primary);
  text-align: left; vertical-align: middle; white-space: nowrap;
}

tbody tr {
  background: var(--layer-01);
  cursor: pointer;
  transition: background-color .07s var(--ease);
}
tbody tr:hover { background: var(--layer-hover-01); }
tbody tr.selected { background: var(--layer-selected-01); }
tbody td {
  height: 48px; padding: 0 16px;
  border-top: 1px solid var(--layer-01);
  border-bottom: 1px solid var(--border-subtle-01);
  color: var(--text-secondary);
  font-size: 14px; letter-spacing: .16px; vertical-align: middle;
  max-width: 320px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
tbody tr:hover td { color: var(--text-primary); border-top-color: var(--layer-hover-01); border-bottom-color: var(--layer-hover-01); }

.td-primary { color: var(--text-primary) !important; }
.td-mono { font-family: var(--mono); font-size: 12px; letter-spacing: .32px; }

.cb-col { width: 48px; padding: 0 0 0 16px !important; cursor: default; }

/* ── Checkbox ────────────────────────────────────────────────── */

input[type="checkbox"] {
  appearance: none; -webkit-appearance: none;
  width: 16px; height: 16px; margin: 0;
  border: 1px solid var(--text-primary); border-radius: 2px;
  background: transparent; cursor: pointer;
  display: inline-grid; place-content: center; vertical-align: middle;
}
input[type="checkbox"]::before {
  content: ''; width: 9px; height: 5px;
  border-left: 2px solid var(--background); border-bottom: 2px solid var(--background);
  transform: rotate(-45deg) translate(1px, -1px); opacity: 0;
}
input[type="checkbox"]:checked, input[type="checkbox"]:indeterminate {
  background: var(--text-primary);
}
input[type="checkbox"]:checked::before { opacity: 1; }
input[type="checkbox"]:indeterminate::before {
  opacity: 1; width: 8px; height: 0; border-left: none; transform: none;
}
input[type="checkbox"]:focus-visible { outline: 2px solid var(--focus); outline-offset: 1px; }

/* ── Pagination ──────────────────────────────────────────────── */

.pagination {
  display: flex; align-items: center; justify-content: space-between;
  min-height: 48px;
  background: var(--layer-01);
  border-top: 1px solid var(--border-subtle-01);
  font-size: 14px; letter-spacing: .16px; color: var(--text-primary);
}
.pagination-info { padding-left: 16px; }
.pagination-right { display: flex; align-items: center; height: 48px; }
.pagination-pages { display: flex; height: 100%; }
.pagination-pages a, .pagination-pages span {
  position: relative;
  display: inline-flex; align-items: center; justify-content: center;
  min-width: 48px; height: 48px; padding: 0 4px;
  color: var(--text-secondary); text-decoration: none;
}
.pagination-pages a:hover { background: var(--layer-hover-01); color: var(--text-primary); }
.pagination-pages .current { color: var(--text-primary); font-weight: 600; }
.pagination-pages .current::after {
  content: ''; position: absolute; left: 12px; right: 12px; bottom: 0;
  height: 4px; background: var(--border-interactive);
}
.pagination-step {
  display: inline-flex; align-items: center; justify-content: center;
  width: 48px; height: 48px;
  border-left: 1px solid var(--border-subtle-01);
  color: var(--text-primary);
}
.pagination-step:hover { background: var(--layer-hover-01); }
.pagination-step.disabled { color: var(--text-placeholder); pointer-events: none; }
.pagination-step .cds-icon { fill: currentColor; }

/* ── Tags ────────────────────────────────────────────────────── */

.tag {
  display: inline-flex; align-items: center;
  min-height: 24px; padding: 0 8px; border-radius: 1rem;
  font-size: 12px; line-height: 1.33333; letter-spacing: .32px;
}
.tag-green { background: var(--tag-green-bg); color: var(--tag-green-fg); }
.tag-gray  { background: var(--tag-gray-bg);  color: var(--tag-gray-fg); }

/* ── Empty state ─────────────────────────────────────────────── */

.empty-state { padding: 48px 16px 64px; max-width: 32rem; cursor: default; white-space: normal; }
.empty-state .cds-icon { fill: var(--text-placeholder); margin-bottom: 16px; }
.empty-state h3 {
  font-size: 20px; font-weight: 400; line-height: 1.4;
  color: var(--text-primary); margin-bottom: 8px;
}
.empty-state p { font-size: 14px; line-height: 1.42857; color: var(--text-secondary); }

/* ── Dashboard ───────────────────────────────────────────────── */

.kpi-row {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1px; margin-bottom: 48px; max-width: 482px;
}
.kpi {
  background: var(--layer-01); padding: 16px; min-height: 112px;
  display: flex; flex-direction: column; justify-content: space-between;
}
.kpi-lbl { font-size: 14px; color: var(--text-secondary); letter-spacing: .16px; }
.kpi-val { font-size: 42px; font-weight: 300; line-height: 1.19; letter-spacing: 0; }

.section-lbl {
  font-size: 16px; font-weight: 600; line-height: 1.375;
  color: var(--text-primary); margin-bottom: 16px;
}

.tile-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1px; margin-bottom: 48px;
}

.tile-clickable {
  position: relative;
  display: flex; flex-direction: column; justify-content: space-between;
  min-height: 128px; padding: 16px 16px 48px;
  background: var(--layer-01); color: var(--text-primary); text-decoration: none;
  outline: 2px solid transparent; outline-offset: -2px;
  transition: background .11s var(--ease);
}
.tile-clickable:hover { background: var(--layer-hover-01); }
.tile-clickable:focus-visible { outline-color: var(--focus); }
.tile-name { font-size: 16px; font-weight: 400; line-height: 1.5; }
.tile-count { font-size: 14px; color: var(--text-secondary); margin-top: 4px; }
.tile-clickable .cds-icon {
  position: absolute; right: 16px; bottom: 16px; fill: var(--interactive);
}

/* ── Forms ───────────────────────────────────────────────────── */

.form-wrap { max-width: 640px; }

.form-card { background: var(--layer-01); }
.form-card-body { padding: 16px 16px 32px; }
.form-card-title { font-size: 20px; font-weight: 400; line-height: 1.4; margin-bottom: 24px; }

.field { margin-bottom: 24px; }
.field:last-child { margin-bottom: 0; }

.field-lbl {
  display: inline-block; margin-bottom: 8px;
  font-size: 12px; line-height: 1.33333; letter-spacing: .32px;
  color: var(--text-secondary);
}
.field-lbl .req { color: var(--text-error); margin-left: 2px; }

.field-input { position: relative; }
.field input:not([type="checkbox"]),
.field select,
.field textarea {
  display: block; width: 100%; height: 40px;
  padding: 0 16px;
  background: var(--field-02);
  border: none; border-bottom: 1px solid var(--border-strong-01); border-radius: 0;
  font-family: var(--font); font-size: 14px; letter-spacing: .16px;
  color: var(--text-primary);
  outline: 2px solid transparent; outline-offset: -2px;
  transition: background-color .07s var(--ease), outline .07s var(--ease);
}
.field input:not([type="checkbox"]):hover,
.field select:hover, .field textarea:hover { background: var(--field-hover-02); }
.field input:focus, .field select:focus, .field textarea:focus { outline-color: var(--focus); }
.field textarea {
  height: auto; min-height: 96px; padding: 11px 16px; resize: vertical;
  font-family: var(--mono); font-size: 12px; line-height: 1.5;
}
.field.has-error input:not([type="checkbox"]),
.field.has-error textarea, .field.has-error select {
  outline-color: var(--support-error); padding-right: 40px;
}
.field-error-icon {
  position: absolute; right: 16px; top: 12px; fill: var(--support-error);
}

.field-hint {
  font-size: 12px; line-height: 1.33333; letter-spacing: .32px;
  color: var(--text-helper); margin-top: 4px;
}
.field-error {
  font-size: 12px; line-height: 1.33333; letter-spacing: .32px;
  color: var(--text-error); margin-top: 4px;
}

.readonly-val {
  min-height: 40px; padding: 11px 16px;
  background: transparent;
  border-bottom: 1px solid var(--border-subtle-01);
  font-family: var(--mono); font-size: 12px; letter-spacing: .32px;
  color: var(--text-secondary);
  overflow-wrap: anywhere;
}

.checkbox-row { display: flex; align-items: center; gap: 8px; min-height: 24px; }
.checkbox-row label { font-size: 14px; letter-spacing: .16px; color: var(--text-primary); cursor: pointer; }

.form-secondary {
  display: flex; flex-wrap: wrap; justify-content: space-between; gap: 8px;
  margin-top: 16px;
}

/* ── Danger dialog ───────────────────────────────────────────── */

.dialog {
  max-width: 48%; min-width: 360px;
  background: var(--layer-01);
  border-top: 3px solid var(--support-error);
}
.dialog-body { padding: 16px 16px 32px; }
.dialog-label {
  font-size: 12px; line-height: 1.33333; letter-spacing: .32px;
  color: var(--text-secondary); margin-bottom: 4px;
}
.dialog h2 { font-size: 20px; font-weight: 400; line-height: 1.4; margin-bottom: 24px; }
.dialog p { font-size: 14px; line-height: 1.42857; padding-right: 20%; margin-bottom: 16px; }
.code-snippet {
  background: var(--layer-02);
  padding: 16px;
  font-family: var(--mono); font-size: 12px; line-height: 1.5; letter-spacing: .32px;
  color: var(--text-primary); white-space: pre-wrap; overflow-wrap: anywhere;
}

/* ── Login ───────────────────────────────────────────────────── */

.login-page { min-height: 100vh; padding-top: var(--header-h); }
.login-wrap { max-width: 400px; padding: 48px 16px; margin-left: 10%; }
.login-heading { font-size: 28px; font-weight: 400; line-height: 1.28572; margin-bottom: 8px; }
.login-sub { font-size: 14px; color: var(--text-secondary); margin-bottom: 32px; }
.login-divider { border: none; border-top: 1px solid var(--border-subtle-01); margin-bottom: 24px; }
.login-wrap .field input:not([type="checkbox"]) { background: var(--field-01); }
.login-wrap .btn { width: 100%; max-width: none; margin-top: 8px; }

/* ── Small screens: side nav becomes a drawer ────────────────── */

@media (max-width: 1056px) {
  .header-menu-btn { display: inline-flex; }
  .header-menu-btn + .header-name { padding-left: 0; }
  .side-nav { transform: translateX(-100%); }
  .side-nav.expanded { transform: none; box-shadow: 0 2px 6px rgba(0,0,0,.3); }
  .side-nav.expanded + .side-nav-overlay {
    display: block; position: fixed; inset: var(--header-h) 0 0 0; z-index: 6000;
    background: rgba(22,22,22,.5);
  }
  .content { margin-left: 0; padding-left: 16px; padding-right: 16px; }
  .login-wrap { margin-left: 0; }
  .dialog { max-width: none; min-width: 0; }
}

@media (max-width: 672px) {
  .btn-set { flex-direction: column-reverse; }
  .btn-set .btn { height: 48px; padding-top: 0; align-items: center; }
  .pagination-pages { display: none; }
  .table-toolbar .btn-primary { min-width: 0; }
  .table-toolbar .btn-label { display: none; }
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { transition: none !important; }
}
''';
