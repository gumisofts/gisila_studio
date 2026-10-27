/// Credential checks and the "disabled" studio. No database is needed: the
/// pool behind `Database.connect` opens connections lazily, and a disabled
/// studio never queries.
library gisila_studio.test.studio_auth_test;

import 'package:gisila_orm/gisila.dart';
import 'package:gisila_studio/gisila_studio.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

const _goodPassword = 'correct-horse-battery';
const _goodSecret = 'k3P9wq0ZcX1vB7nM2aS8dF4gH6jL5tRyU';

Future<Database> _db() => Database.connect(DatabaseConfig(connections: [
      DatabaseConnection(
        name: 'default',
        type: DatabaseType.postgresql,
        host: '127.0.0.1',
        port: 1,
        database: 'none',
        username: 'none',
        password: 'none',
      ),
    ]));

Future<Response> _get(GisilaStudio studio, String path) async =>
    await studio.handler(prefix: '/studio')(Request(
        'GET', Uri.parse('http://localhost/studio$path'),
        handlerPath: '/studio/'));

void main() {
  group('credentialWeakness', () {
    test('accepts a long, distinct password', () {
      expect(credentialWeakness('admin', _goodPassword), isNull);
    });

    test('rejects short, username-equal and placeholder passwords', () {
      expect(credentialWeakness('admin', 'admin'), contains('shorter'));
      expect(credentialWeakness('administrator1', 'Administrator1'),
          contains('same as the username'));
      expect(credentialWeakness('admin', 'change-me-please'),
          contains('placeholder'));
      expect(credentialWeakness('', _goodPassword), contains('username'));
    });

    test('rejects short and placeholder signing secrets', () {
      expect(secretWeakness('secret'), contains('shorter'));
      expect(secretWeakness('change-me-to-a-random-secret-value-x'),
          contains('placeholder'));
      expect(secretWeakness(_goodSecret), isNull);
    });

    test('strategies report their own weakness', () {
      expect(
          SessionStudioAuth(username: 'a', password: 'admin').weaknessReason(),
          isNotNull);
      expect(
          JwtStudioAuth(username: 'a', password: _goodPassword, secret: 'x')
              .weaknessReason(),
          contains('signing secret'));
      expect(
          JwtStudioAuth(
                  username: 'a', password: _goodPassword, secret: _goodSecret)
              .weaknessReason(),
          isNull);
    });
  });

  group('GisilaStudio refuses insecure setups', () {
    late Database db;
    setUpAll(() async => db = await _db());
    tearDownAll(() => db.close());

    test('no login → 503 disabled page on every path', () async {
      final studio = GisilaStudio(db: db, username: '', password: '');
      for (final path in ['/', '/login/', '/users/', '/users/1/delete/']) {
        final res = await _get(studio, path);
        expect(res.statusCode, 503, reason: path);
        expect(await res.readAsString(), contains('Studio is disabled'));
      }
    });

    test('weak credentials → disabled', () async {
      final studio = GisilaStudio(db: db, username: 'admin', password: 'admin');
      expect((await _get(studio, '/login/')).statusCode, 503);
    });

    test('a weak JWT secret → disabled', () async {
      final studio = GisilaStudio(
          db: db, username: 'admin', password: _goodPassword, secret: 'short');
      expect((await _get(studio, '/login/')).statusCode, 503);
    });

    test('strong credentials → login page', () async {
      final studio = GisilaStudio(
          db: db,
          username: 'admin',
          password: _goodPassword,
          secret: _goodSecret);
      final res = await _get(studio, '/login/');
      expect(res.statusCode, 200);
      expect(await res.readAsString(), contains('Log in to'));
    });

    test('allowInsecure serves weak credentials', () async {
      final studio = GisilaStudio(
          db: db, username: 'admin', password: 'admin', allowInsecure: true);
      expect((await _get(studio, '/login/')).statusCode, 200);
    });

    test('allowUnauthenticated serves with no login', () async {
      final studio = GisilaStudio(
          db: db, username: '', password: '', allowUnauthenticated: true);
      // No models registered and no DB: the dashboard renders without queries.
      expect((await _get(studio, '/')).statusCode, isNot(503));
    });

    test('a secret switches the shorthand to JWT auth', () async {
      final studio = GisilaStudio(
          db: db,
          username: 'admin',
          password: _goodPassword,
          secret: _goodSecret);
      final res = await studio.handler(prefix: '/studio')(Request(
          'POST', Uri.parse('http://localhost/studio/login/'),
          handlerPath: '/studio/',
          body: 'username=admin&password=$_goodPassword',
          headers: {'content-type': 'application/x-www-form-urlencoded'}));
      expect(res.statusCode, 302);
      expect(res.headers['set-cookie'], startsWith('_studio_jwt='));
      expect(res.headers['set-cookie'], contains('Path=/studio'));
    });
  });

  group('ST-05 forms, cookies and sign-in', () {
    late Handler h;

    setUp(() async {
      final studio = GisilaStudio(
          db: await _db(),
          username: 'admin',
          password: _goodPassword,
          secret: _goodSecret);
      h = studio.handler(prefix: '/studio');
    });

    Future<Response> send(String method, String path,
            {String? body, Map<String, String> headers = const {}}) async =>
        await h(Request(method, Uri.parse('http://localhost/studio$path'),
            handlerPath: '/studio/',
            body: body,
            headers: {
              'content-type': 'application/x-www-form-urlencoded',
              ...headers,
            }));

    Future<Response> login(String password,
            {Map<String, String> headers = const {}}) =>
        send('POST', '/login/',
            body: 'username=admin&password=$password', headers: headers);

    Future<String> cookie() async {
      final res = await login(_goodPassword);
      return res.headers['set-cookie']!.split(';').first;
    }

    test('POSTs need the session CSRF token', () async {
      final c = await cookie();
      final token = c.split('=').skip(1).join('=');
      final missing = await send('POST', '/logout/', headers: {'cookie': c});
      expect(missing.statusCode, 403);
      final wrong = await send('POST', '/logout/',
          body: '_csrf=nope', headers: {'cookie': c});
      expect(wrong.statusCode, 403);
      final ok = await send('POST', '/logout/',
          body: '_csrf=${studioCsrfToken(token)}', headers: {'cookie': c});
      expect(ok.statusCode, 302);
    });

    test('rendered POST forms carry the token', () async {
      final c = await cookie();
      final token = c.split('=').skip(1).join('=');
      final res = await send('GET', '/', headers: {'cookie': c});
      final html = await res.readAsString();
      expect(html, contains('<form method="post" action="/studio/logout/"'));
      expect(html, contains('name="_csrf" value="${studioCsrfToken(token)}"'));
    });

    test('the cookie is Secure behind an HTTPS proxy', () async {
      final plain = await login(_goodPassword);
      expect(plain.headers['set-cookie'], isNot(contains('Secure')));
      final https =
          await login(_goodPassword, headers: {'x-forwarded-proto': 'https'});
      expect(https.headers['set-cookie'], contains('; Secure'));
    });

    test('repeated failures lock sign-in for a while', () async {
      for (var i = 0; i < 10; i++) {
        expect((await login('wrong-password-$i')).statusCode, 401);
      }
      final locked = await login(_goodPassword);
      expect(locked.statusCode, 429);
      expect(locked.headers['retry-after'], isNotNull);
    });

    test('constantTimeEquals', () {
      expect(constantTimeEquals('abc', 'abc'), isTrue);
      expect(constantTimeEquals('abc', 'abd'), isFalse);
      expect(constantTimeEquals('abc', 'abcd'), isFalse);
    });
  });
}
