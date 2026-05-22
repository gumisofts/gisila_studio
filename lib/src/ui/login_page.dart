/// Login page for Gisila Studio.
library gisila_studio.ui.login_page;

import 'theme.dart';

/// Renders the full standalone login page HTML.
///
/// [prefix] is the URL prefix where the studio is mounted.
/// [studioTitle] is displayed in the header.
/// [errorMessage] is shown when credentials are wrong.
String renderLoginPage({
  required String prefix,
  String? studioTitle,
  String? errorMessage,
}) {
  final title = studioTitle ?? 'Gisila Studio';
  final initial = title.isNotEmpty ? title[0].toUpperCase() : 'G';
  final errHtml = errorMessage != null
      ? '''
      <div class="login-error">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4m0 4h.01"/></svg>
        <span>${_esc(errorMessage)}</span>
      </div>'''
      : '';

  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sign in — ${_esc(title)}</title>
  <style>$studioStyles
/* ── Login page overrides ──────────────────────────────────── */
body {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: var(--c-bg);
}

.login-wrap {
  width: 100%;
  max-width: 360px;
  padding: 0 16px;
}

.login-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 28px;
  justify-content: center;
}

.login-logo .logo-mark {
  width: 36px;
  height: 36px;
  border-radius: 9px;
  background: var(--c-accent);
  color: #fff;
  font-size: 17px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  letter-spacing: -.5px;
}

.login-logo .logo-name {
  font-size: 15px;
  font-weight: 600;
  color: var(--c-text);
}

.login-card {
  background: var(--c-surface);
  border: 1px solid var(--c-border);
  border-radius: var(--r-xl);
  padding: 28px 24px 24px;
}

.login-heading {
  font-size: 16px;
  font-weight: 600;
  color: var(--c-text);
  margin-bottom: 4px;
}

.login-sub {
  font-size: 12px;
  color: var(--c-text2);
  margin-bottom: 20px;
}

.login-field {
  margin-bottom: 14px;
}

.login-field label {
  display: block;
  font-size: 12px;
  font-weight: 500;
  color: var(--c-text2);
  margin-bottom: 5px;
}

.login-field input {
  width: 100%;
  background: var(--c-surface2);
  border: 1px solid var(--c-border2);
  border-radius: var(--r);
  color: var(--c-text);
  font-family: var(--font);
  font-size: 13px;
  padding: 8px 11px;
  outline: none;
  transition: border-color .15s;
}

.login-field input:focus {
  border-color: var(--c-accent);
  box-shadow: 0 0 0 3px var(--c-accent-soft);
}

.login-error {
  display: flex;
  align-items: center;
  gap: 7px;
  background: var(--c-red-soft);
  border: 1px solid rgba(248,113,113,.2);
  border-radius: var(--r);
  color: var(--c-red);
  font-size: 12.5px;
  padding: 8px 10px;
  margin-bottom: 14px;
}

.login-btn {
  width: 100%;
  background: var(--c-accent);
  border: none;
  border-radius: var(--r);
  color: #fff;
  cursor: pointer;
  font-family: var(--font);
  font-size: 13px;
  font-weight: 500;
  padding: 9px;
  transition: background .15s;
  margin-top: 4px;
}

.login-btn:hover { background: var(--c-accent-h); }
</style>
</head>
<body>
  <div class="login-wrap">
    <div class="login-logo">
      <div class="logo-mark">$initial</div>
      <div class="logo-name">${_esc(title)}</div>
    </div>
    <div class="login-card">
      <div class="login-heading">Sign in</div>
      <div class="login-sub">Enter your admin credentials to continue.</div>
      $errHtml
      <form method="post" action="$prefix/login/" autocomplete="on">
        <div class="login-field">
          <label for="username">Username</label>
          <input id="username" name="username" type="text"
                 autocomplete="username" autofocus required>
        </div>
        <div class="login-field">
          <label for="password">Password</label>
          <input id="password" name="password" type="password"
                 autocomplete="current-password" required>
        </div>
        <button class="login-btn" type="submit">Sign in</button>
      </form>
    </div>
  </div>
</body>
</html>''';
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
