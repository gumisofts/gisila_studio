/// Session-based authentication for Gisila Studio.
library gisila_studio.auth;

import 'dart:convert';
import 'dart:math';

const _cookieName = '_studio_sid';

/// Manages in-memory sessions for the studio admin.
///
/// Credentials are typically supplied via the `STUDIO_USERNAME` and
/// `STUDIO_PASSWORD` environment variables, but can be passed directly.
class StudioAuth {
  final String username;
  final String password;

  final _sessions = <String>{};
  final _rng = Random.secure();

  StudioAuth({required this.username, required this.password});

  /// Creates a new session token, stores it, and returns it.
  String createSession() {
    final bytes = List<int>.generate(32, (_) => _rng.nextInt(256));
    final token = base64Url.encode(bytes);
    _sessions.add(token);
    return token;
  }

  /// Removes a session token (logout).
  void destroySession(String token) => _sessions.remove(token);

  /// Returns true if [token] corresponds to an active session.
  bool isValidToken(String token) => _sessions.contains(token);

  /// Extracts the session token from the `Cookie` request header, or null.
  String? tokenFromCookieHeader(String? cookieHeader) {
    if (cookieHeader == null) return null;
    for (final part in cookieHeader.split(';')) {
      final trimmed = part.trim();
      final idx = trimmed.indexOf('=');
      if (idx < 0) continue;
      final name = trimmed.substring(0, idx).trim();
      if (name == _cookieName) return trimmed.substring(idx + 1).trim();
    }
    return null;
  }

  /// Returns true if the request headers contain a valid session cookie.
  bool isAuthenticated(Map<String, String> headers) {
    final cookieHeader = headers['cookie'];
    final token = tokenFromCookieHeader(cookieHeader);
    if (token == null) return false;
    return isValidToken(token);
  }

  /// Returns the current session token from the request headers, or null.
  String? currentToken(Map<String, String> headers) {
    final cookieHeader = headers['cookie'];
    return tokenFromCookieHeader(cookieHeader);
  }

  /// Produces a `Set-Cookie` header value that sets the session cookie.
  String setCookieHeader(String token) =>
      '$_cookieName=$token; Path=/; HttpOnly; SameSite=Lax';

  /// Produces a `Set-Cookie` header value that clears the session cookie.
  String clearCookieHeader() =>
      '$_cookieName=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0';
}
