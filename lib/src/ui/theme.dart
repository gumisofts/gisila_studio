/// CSS stylesheet for Gisila Studio.
library gisila_studio.ui.theme;

const String studioStyles = r'''
@import url('https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,300;0,14..32,400;0,14..32,500;0,14..32,600;0,14..32,700;1,14..32,400&display=swap');

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --sidebar-w: 240px;
  --topbar-h: 48px;

  --c-bg:      #0f0f12;
  --c-sidebar: #111115;
  --c-surface: #18181c;
  --c-surface2:#1e1e23;
  --c-border:  rgba(255,255,255,.07);
  --c-border2: rgba(255,255,255,.11);

  --c-text:  #ededed;
  --c-text2: #a0a0ab;
  --c-text3: #64646e;

  --c-accent:      #6366f1;
  --c-accent-h:    #4f52e0;
  --c-accent-soft: rgba(99,102,241,.12);

  --c-green:      #22c55e;
  --c-green-soft: rgba(34,197,94,.12);
  --c-red:        #f87171;
  --c-red-soft:   rgba(248,113,113,.1);
  --c-amber:      #fbbf24;
  --c-amber-soft: rgba(251,191,36,.1);
  --c-blue:       #60a5fa;
  --c-blue-soft:  rgba(96,165,250,.1);

  --r:    7px;
  --r-lg: 10px;
  --r-xl: 14px;

  --font: 'Inter', system-ui, -apple-system, sans-serif;
  --mono: 'SF Mono', 'Fira Code', ui-monospace, monospace;
}

body {
  font-family: var(--font);
  font-size: 13px;
  line-height: 1.5;
  color: var(--c-text);
  background: var(--c-bg);
  display: flex;
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
}

/* ── Sidebar ──────────────────────────────────────────────────── */

.sidebar {
  width: var(--sidebar-w);
  background: var(--c-sidebar);
  border-right: 1px solid var(--c-border);
  display: flex;
  flex-direction: column;
  position: fixed;
  top: 0; left: 0; bottom: 0;
  z-index: 100;
  overflow: hidden;
}

.sidebar-logo {
  display: flex; align-items: center; gap: 10px;
  padding: 16px 14px 14px;
  text-decoration: none;
  border-bottom: 1px solid var(--c-border);
  flex-shrink: 0;
}

.logo-mark {
  width: 28px; height: 28px;
  background: var(--c-accent);
  border-radius: 7px;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 700; color: white;
  flex-shrink: 0;
  box-shadow: 0 0 0 1px rgba(99,102,241,.4), 0 4px 10px rgba(99,102,241,.25);
}

.logo-name { font-size: 13px; font-weight: 600; color: var(--c-text); }
.logo-sub  { font-size: 11px; color: var(--c-text3); margin-top: 1px; }

.sidebar-search {
  padding: 10px 10px 6px;
  flex-shrink: 0;
}

.sidebar-search-inner { position: relative; }
.sidebar-search-inner svg {
  position: absolute; left: 9px; top: 50%; transform: translateY(-50%);
  color: var(--c-text3); pointer-events: none;
}

.sidebar-search input {
  width: 100%;
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: 6px;
  padding: 7px 10px 7px 28px;
  font-size: 12px; font-family: var(--font); color: var(--c-text);
  outline: none; transition: border-color .15s;
}
.sidebar-search input::placeholder { color: var(--c-text3); }
.sidebar-search input:focus { border-color: var(--c-accent); background: var(--c-surface2); }

.sidebar-body {
  flex: 1; overflow-y: auto;
  padding: 6px 8px 16px;
  scrollbar-width: none;
}
.sidebar-body::-webkit-scrollbar { display: none; }

.nav-group { margin-bottom: 18px; }
.nav-group-label {
  font-size: 10.5px; font-weight: 600;
  letter-spacing: .06em; text-transform: uppercase;
  color: var(--c-text3);
  padding: 0 8px; margin-bottom: 3px;
}

.nav-item {
  display: flex; align-items: center; justify-content: space-between;
  padding: 6px 8px;
  border-radius: 6px;
  color: var(--c-text2); text-decoration: none;
  font-size: 13px; font-weight: 450;
  transition: background .1s, color .1s;
}
.nav-item:hover { background: rgba(255,255,255,.05); color: var(--c-text); }
.nav-item.active {
  background: var(--c-accent-soft);
  color: #a5b4fc; font-weight: 500;
}
.nav-badge {
  font-size: 10.5px; font-weight: 500;
  background: rgba(255,255,255,.06);
  color: var(--c-text3);
  padding: 1px 6px; border-radius: 10px;
}
.nav-item.active .nav-badge { background: rgba(99,102,241,.18); color: #a5b4fc; }
.nav-item.nav-hidden { display: none; }
.nav-group.nav-group-hidden { display: none; }

.sidebar-footer {
  padding: 10px 8px;
  border-top: 1px solid var(--c-border);
  flex-shrink: 0;
}
.sidebar-footer a {
  display: flex; align-items: center; gap: 8px;
  padding: 6px 8px; border-radius: 6px;
  color: var(--c-text3); text-decoration: none; font-size: 12.5px;
}
.sidebar-footer a:hover { background: rgba(255,255,255,.05); color: var(--c-text2); }
.sidebar-logout {
  display: flex; align-items: center; gap: 8px;
  width: 100%; padding: 6px 8px; border-radius: 6px;
  background: none; border: none; cursor: pointer;
  color: var(--c-text3); font-family: var(--font); font-size: 12.5px;
  text-align: left;
}
.sidebar-logout:hover { background: rgba(248,113,113,.08); color: var(--c-red); }

/* ── Main ────────────────────────────────────────────────────── */

.main-wrap {
  margin-left: var(--sidebar-w);
  flex: 1; display: flex; flex-direction: column; min-height: 100vh;
}

.topbar {
  height: var(--topbar-h);
  border-bottom: 1px solid var(--c-border);
  display: flex; align-items: center; padding: 0 24px; gap: 8px;
  background: var(--c-bg);
  position: sticky; top: 0; z-index: 50;
}

.breadcrumb {
  display: flex; align-items: center; gap: 6px;
  font-size: 12.5px; color: var(--c-text3); flex: 1; min-width: 0;
  overflow: hidden;
}
.breadcrumb a { color: var(--c-text3); text-decoration: none; }
.breadcrumb a:hover { color: var(--c-text2); }
.breadcrumb .sep { opacity: .4; flex-shrink: 0; }
.breadcrumb .crumb-current {
  color: var(--c-text2); font-weight: 500;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}

.topbar-actions { margin-left: auto; display: flex; gap: 8px; align-items: center; flex-shrink: 0; }

.content { flex: 1; padding: 24px 32px 48px; }

/* ── Page header ─────────────────────────────────────────────── */

.page-hdr {
  margin-bottom: 20px;
}
.page-title {
  font-size: 22px; font-weight: 600; letter-spacing: -.3px;
  color: var(--c-text); line-height: 1.2;
}
.page-meta { font-size: 12.5px; color: var(--c-text3); margin-top: 3px; }

/* ── Buttons ─────────────────────────────────────────────────── */

.btn {
  display: inline-flex; align-items: center; justify-content: center; gap: 6px;
  padding: 7px 14px;
  border-radius: var(--r);
  font-size: 12.5px; font-weight: 500; font-family: var(--font);
  border: 1px solid transparent;
  cursor: pointer; text-decoration: none;
  transition: all .12s;
  white-space: nowrap; line-height: 1;
}
.btn:active { transform: scale(.97); }

.btn-primary {
  background: var(--c-accent); color: white;
  box-shadow: 0 1px 3px rgba(99,102,241,.35), inset 0 1px 0 rgba(255,255,255,.08);
}
.btn-primary:hover { background: var(--c-accent-h); }

.btn-secondary {
  background: var(--c-surface2); color: var(--c-text2);
  border-color: var(--c-border);
}
.btn-secondary:hover { background: rgba(255,255,255,.07); color: var(--c-text); }

.btn-ghost {
  background: transparent; color: var(--c-text3); border-color: transparent;
}
.btn-ghost:hover { background: rgba(255,255,255,.05); color: var(--c-text2); }

.btn-danger {
  background: rgba(239,68,68,.14); color: var(--c-red);
  border-color: rgba(239,68,68,.18);
}
.btn-danger:hover { background: rgba(239,68,68,.22); }

.btn-danger-outline {
  background: transparent; color: var(--c-text3);
  border-color: var(--c-border);
}
.btn-danger-outline:hover { background: rgba(239,68,68,.08); color: var(--c-red); border-color: rgba(239,68,68,.2); }

.btn-sm { padding: 5px 10px; font-size: 11.5px; }
.btn-lg { padding: 9px 18px; font-size: 13.5px; }

/* ── Toast ───────────────────────────────────────────────────── */

.toast {
  display: flex; align-items: center; gap: 10px;
  background: var(--c-surface2);
  border: 1px solid var(--c-border2);
  border-radius: var(--r);
  padding: 10px 14px;
  font-size: 13px; font-weight: 450;
  margin-bottom: 20px;
  box-shadow: 0 8px 24px rgba(0,0,0,.4);
  animation: toastIn .2s ease;
}
@keyframes toastIn {
  from { opacity: 0; transform: translateY(-6px); }
  to   { opacity: 1; transform: translateY(0); }
}
.toast-dot {
  width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0;
}
.toast-ok { border-color: rgba(34,197,94,.2); }
.toast-ok .toast-dot { background: var(--c-green); box-shadow: 0 0 6px rgba(34,197,94,.5); }
.toast-err { border-color: rgba(248,113,113,.2); }
.toast-err .toast-dot { background: var(--c-red); }
.toast-dismiss {
  margin-left: auto; background: none; border: none;
  cursor: pointer; color: var(--c-text3); opacity: .6;
  padding: 3px; display: flex; border-radius: 4px;
}
.toast-dismiss:hover { opacity: 1; background: rgba(255,255,255,.06); }

/* ── Table card ──────────────────────────────────────────────── */

.table-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  overflow: hidden;
}

.table-toolbar {
  display: flex; align-items: center; gap: 10px;
  padding: 12px 16px;
  border-bottom: 1px solid var(--c-border);
}

.search-wrap { position: relative; }
.search-wrap svg {
  position: absolute; left: 9px; top: 50%; transform: translateY(-50%);
  color: var(--c-text3); pointer-events: none;
}
.search-wrap input {
  background: var(--c-surface2);
  border: 1px solid var(--c-border);
  border-radius: 6px;
  padding: 7px 12px 7px 30px;
  font-size: 12.5px; font-family: var(--font); color: var(--c-text);
  outline: none; width: 260px;
  transition: border-color .12s;
}
.search-wrap input::placeholder { color: var(--c-text3); }
.search-wrap input:focus { border-color: var(--c-accent); background: rgba(99,102,241,.03); }

table { width: 100%; border-collapse: collapse; }

thead th {
  padding: 10px 14px;
  text-align: left;
  font-size: 10.5px; font-weight: 600;
  letter-spacing: .05em; text-transform: uppercase;
  color: var(--c-text3);
  border-bottom: 1px solid var(--c-border);
  white-space: nowrap;
}
thead th:first-child { padding-left: 18px; }

tbody tr {
  border-bottom: 1px solid var(--c-border);
  transition: background .08s;
  cursor: pointer;
}
tbody tr:last-child { border-bottom: none; }
tbody tr:hover { background: rgba(255,255,255,.025); }

tbody td {
  padding: 11px 14px;
  color: var(--c-text2);
  vertical-align: middle;
  max-width: 260px; overflow: hidden;
  text-overflow: ellipsis; white-space: nowrap;
}
tbody td:first-child { padding-left: 18px; }

.td-primary { color: var(--c-text) !important; font-weight: 500; }
.td-mono { font-family: var(--mono); font-size: 11.5px; color: var(--c-text3) !important; }

/* ── Pill badges ─────────────────────────────────────────────── */

.pill {
  display: inline-flex; align-items: center;
  padding: 2px 8px; border-radius: 20px;
  font-size: 11px; font-weight: 500;
}
.pill-green { background: var(--c-green-soft); color: var(--c-green); }
.pill-red   { background: var(--c-red-soft);   color: var(--c-red);   }
.pill-amber { background: var(--c-amber-soft);  color: var(--c-amber); }
.pill-blue  { background: var(--c-blue-soft);   color: var(--c-blue);  }
.pill-gray  { background: rgba(255,255,255,.06); color: var(--c-text3); }

.bool-yes { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 20px; font-size: 11px; font-weight: 500; background: var(--c-green-soft); color: var(--c-green); }
.bool-no  { display: inline-flex; align-items: center; padding: 2px 8px; border-radius: 20px; font-size: 11px; font-weight: 500; background: rgba(255,255,255,.06); color: var(--c-text3); }

/* ── Checkbox ────────────────────────────────────────────────── */

.cb-col { width: 44px; padding: 11px 8px 11px 18px !important; cursor: default; }
.cb-col input, .row-cb { accent-color: var(--c-accent); cursor: pointer; }

/* ── Selection bar ───────────────────────────────────────────── */

.sel-bar {
  display: none; align-items: center; gap: 10px;
  background: var(--c-surface2);
  border: 1px solid var(--c-border2);
  border-radius: var(--r);
  padding: 8px 14px;
  margin-bottom: 12px;
  font-size: 12.5px; color: var(--c-text2);
  animation: slideUp .15s ease;
}
@keyframes slideUp {
  from { opacity: 0; transform: translateY(4px); }
  to   { opacity: 1; transform: translateY(0); }
}
.sel-bar.visible { display: flex; }
.sel-count { font-weight: 600; color: var(--c-text); }
.sel-sep { width: 1px; height: 16px; background: var(--c-border2); margin: 0 2px; }

/* ── Pagination ──────────────────────────────────────────────── */

.pagination {
  display: flex; align-items: center; justify-content: space-between;
  padding: 11px 18px;
  border-top: 1px solid var(--c-border);
}
.pagination-info { font-size: 12px; color: var(--c-text3); }
.pagination-links { display: flex; gap: 3px; }
.pagination-links a, .pagination-links span {
  display: inline-flex; align-items: center; justify-content: center;
  min-width: 30px; height: 30px; padding: 0 4px;
  border-radius: 6px; font-size: 12.5px; font-weight: 500;
  color: var(--c-text3); text-decoration: none;
  border: 1px solid var(--c-border); background: transparent;
  transition: all .1s;
}
.pagination-links a:hover { background: rgba(255,255,255,.06); color: var(--c-text2); border-color: var(--c-border2); }
.pagination-links .current { background: var(--c-accent); color: white; border-color: var(--c-accent); }
.pagination-links .disabled { opacity: .3; pointer-events: none; }

/* ── Empty state ─────────────────────────────────────────────── */

.empty-state {
  text-align: center; padding: 56px 24px;
}
.empty-icon {
  width: 44px; height: 44px;
  background: var(--c-surface2);
  border-radius: var(--r);
  display: flex; align-items: center; justify-content: center;
  margin: 0 auto 14px; color: var(--c-text3);
}
.empty-state h3 { font-size: 14px; font-weight: 500; color: var(--c-text); margin-bottom: 6px; }
.empty-state p { font-size: 12.5px; color: var(--c-text3); }

/* ── Dashboard ───────────────────────────────────────────────── */

.dash-hero {
  border: 1px solid var(--c-border);
  border-radius: var(--r-xl);
  padding: 22px 28px;
  margin-bottom: 28px;
  background: linear-gradient(135deg, rgba(99,102,241,.07) 0%, transparent 60%);
  position: relative; overflow: hidden;
}
.dash-hero::before {
  content: '';
  position: absolute; right: -60px; top: -60px;
  width: 200px; height: 200px;
  background: radial-gradient(circle, rgba(99,102,241,.15) 0%, transparent 70%);
  border-radius: 50%;
}
.dash-hero h1 { font-size: 20px; font-weight: 600; letter-spacing: -.3px; margin-bottom: 6px; }
.dash-hero p { font-size: 13px; color: var(--c-text2); max-width: 440px; }
.dash-kpis { display: flex; gap: 28px; margin-top: 16px; flex-wrap: wrap; }
.kpi-val { font-size: 22px; font-weight: 700; color: var(--c-text); line-height: 1; }
.kpi-lbl { font-size: 11.5px; color: var(--c-text3); margin-top: 3px; }

.section-lbl {
  font-size: 11px; font-weight: 600; letter-spacing: .05em; text-transform: uppercase;
  color: var(--c-text3); margin-bottom: 8px; margin-top: 4px;
}

.model-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(196px, 1fr));
  gap: 8px; margin-bottom: 24px;
}

.model-tile {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r);
  padding: 13px 15px;
  text-decoration: none; color: inherit;
  display: flex; align-items: center; gap: 12px;
  transition: border-color .15s, background .15s;
}
.model-tile:hover { border-color: var(--c-border2); background: var(--c-surface2); }
.model-tile-ic {
  width: 30px; height: 30px;
  background: var(--c-accent-soft);
  border-radius: 7px;
  display: flex; align-items: center; justify-content: center;
  font-size: 11.5px; font-weight: 700; color: #a5b4fc;
  flex-shrink: 0;
}
.model-tile-name { font-size: 13px; font-weight: 500; color: var(--c-text); }
.model-tile-count { font-size: 11.5px; color: var(--c-text3); margin-top: 1px; }

/* ── Forms ───────────────────────────────────────────────────── */

.form-wrap { max-width: 580px; }

.form-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-lg);
  overflow: hidden; margin-bottom: 8px;
}

.form-card-title {
  font-size: 11.5px; font-weight: 600;
  letter-spacing: .04em; text-transform: uppercase;
  color: var(--c-text3);
  padding: 13px 20px;
  border-bottom: 1px solid var(--c-border);
}

.field {
  padding: 15px 20px;
  border-bottom: 1px solid var(--c-border);
}
.field:last-child { border-bottom: none; }
.field.has-error { background: rgba(248,113,113,.02); }

.field-lbl {
  display: block; font-size: 12.5px; font-weight: 500;
  color: var(--c-text2); margin-bottom: 6px;
}
.field-lbl .req { color: var(--c-red); margin-left: 3px; }

.field input[type="text"],
.field input[type="number"],
.field input[type="email"],
.field input[type="password"],
.field input[type="date"],
.field input[type="time"],
.field input[type="datetime-local"],
.field select,
.field textarea {
  width: 100%;
  background: var(--c-surface2);
  border: 1px solid var(--c-border);
  border-radius: 6px;
  padding: 9px 12px;
  font-size: 13px; font-family: var(--font); color: var(--c-text);
  outline: none; transition: border-color .12s, box-shadow .12s;
}
.field input:focus, .field select:focus, .field textarea:focus {
  border-color: var(--c-accent);
  box-shadow: 0 0 0 3px rgba(99,102,241,.1);
  background: rgba(99,102,241,.02);
}
.field textarea { min-height: 90px; resize: vertical; font-family: var(--mono); font-size: 12.5px; }
.field-hint { font-size: 11.5px; color: var(--c-text3); margin-top: 5px; }
.field-error { font-size: 11.5px; color: var(--c-red); margin-top: 5px; }

.readonly-val {
  padding: 9px 12px;
  background: rgba(255,255,255,.025);
  border: 1px solid var(--c-border);
  border-radius: 6px;
  font-family: var(--mono); font-size: 12px; color: var(--c-text3);
}

.checkbox-row { display: flex; align-items: center; gap: 9px; }
.checkbox-row input { accent-color: var(--c-accent); width: 16px; height: 16px; cursor: pointer; }
.checkbox-row label { font-size: 13px; color: var(--c-text2); cursor: pointer; }

.form-footer {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 0 0; flex-wrap: wrap; gap: 10px;
}
.form-footer-left, .form-footer-right {
  display: flex; align-items: center; gap: 8px;
}
.form-footer-link {
  font-size: 12px; color: var(--c-text3); text-decoration: none; cursor: pointer;
}
.form-footer-link:hover { color: var(--c-text2); }
.form-footer-link.danger:hover { color: var(--c-red); }

/* ── Delete panel ────────────────────────────────────────────── */

.del-panel {
  background: var(--c-surface);
  border: 1px solid rgba(248,113,113,.15);
  border-radius: var(--r-lg);
  padding: 24px; max-width: 440px;
}
.del-ic {
  width: 40px; height: 40px;
  background: var(--c-red-soft);
  border-radius: var(--r);
  display: flex; align-items: center; justify-content: center;
  color: var(--c-red); margin-bottom: 14px;
}
.del-panel h2 { font-size: 16px; font-weight: 600; margin-bottom: 8px; }
.del-panel p { font-size: 13px; color: var(--c-text2); line-height: 1.6; }
.del-record {
  background: rgba(255,255,255,.02); border: 1px solid var(--c-border);
  border-radius: 6px; padding: 10px 14px;
  font-family: var(--mono); font-size: 11.5px; color: var(--c-text3);
  margin: 14px 0 20px; line-height: 1.8;
}
.del-actions { display: flex; gap: 8px; }

/* ── Utils ───────────────────────────────────────────────────── */

.text-muted  { color: var(--c-text3); }
.text-sm     { font-size: 11.5px; }
.d-flex      { display: flex; }
.gap-8       { gap: 8px; }
.align-center{ align-items: center; }
''';
