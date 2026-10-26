/// Login page for Gisila Studio.
library gisila_studio.ui.login_page;

import 'icons.dart';
import 'layout.dart';
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
  final errHtml = errorMessage != null
      ? '''
      <div class="notification notification-error" role="alert">
        ${icon('error-filled', size: 20)}
        <div><span class="notification-title">Error</span>${_esc(errorMessage)}</div>
      </div>'''
      : '';

  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Log in — ${_esc(title)}</title>
  <style>$studioStyles</style>
</head>
<body>
  ${renderHeader(prefix: prefix, studioTitle: title)}
  <main class="login-page">
    <div class="login-wrap">
      <h1 class="login-heading">Log in to ${_esc(title)}</h1>
      <p class="login-sub">Use your admin credentials to continue.</p>
      <hr class="login-divider">
      $errHtml
      <form method="post" action="$prefix/login/" autocomplete="on">
        <div class="field">
          <label class="field-lbl" for="username">Username</label>
          <input id="username" name="username" type="text"
                 autocomplete="username" autofocus required>
        </div>
        <div class="field">
          <label class="field-lbl" for="password">Password</label>
          <input id="password" name="password" type="password"
                 autocomplete="current-password" required>
        </div>
        <button class="btn btn-primary" type="submit">Continue${icon('arrow-right')}</button>
      </form>
    </div>
  </main>
</body>
</html>''';
}

/// The page served instead of the studio when it refuses to run with an
/// insecure setup. The reason goes to the server log, not to the visitor.
String renderDisabledPage(
        {required String prefix, required String studioTitle}) =>
    '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Unavailable — ${_esc(studioTitle)}</title>
  <style>$studioStyles</style>
</head>
<body>
  ${renderHeader(prefix: prefix, studioTitle: studioTitle)}
  <main class="login-page">
    <div class="login-wrap">
      <h1 class="login-heading">Studio is disabled</h1>
      <div class="notification notification-error" role="alert">
        ${icon('error-filled', size: 20)}
        <div>Its login is not configured securely, so it is switched off. The server log says what to change.</div>
      </div>
    </div>
  </main>
</body>
</html>''';

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
