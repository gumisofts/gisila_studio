/// Studio list and form handling against a real Postgres.
///
/// Needs Postgres on localhost:5454 (user/password `postgres`), the same
/// throwaway database the gisila_orm tests use; skipped when it isn't
/// reachable.
library;

import 'dart:io';

import 'package:gisila_orm/gisila.dart';
import 'package:gisila_studio/gisila_studio.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

Future<bool> _reachable() async {
  try {
    final s = await Socket.connect('127.0.0.1', 5454,
        timeout: const Duration(seconds: 1));
    s.destroy();
    return true;
  } on SocketException {
    return false;
  }
}

const _items = TableMeta<Map<String, dynamic>>(
  tableName: 'studio_test_items',
  columnNames: ['id', 'qty', 'created_at', 'note'],
  fromRow: _identity,
);
const _big = TableMeta<Map<String, dynamic>>(
  tableName: 'studio_test_big',
  columnNames: ['id'],
  fromRow: _identity,
);
Map<String, dynamic> _identity(Map<String, dynamic> r) => r;

void main() async {
  final skip = await _reachable() ? false : 'no Postgres on localhost:5454';
  late Database db;
  late Handler handler;

  setUpAll(() async {
    if (skip != false) return;
    db = await Database.connect(DatabaseConfig(connections: [
      DatabaseConnection(
        name: 'default',
        type: DatabaseType.postgresql,
        host: '127.0.0.1',
        port: 5454,
        database: 'postgres',
        username: 'postgres',
        password: 'postgres',
        maxConnections: 2,
      ),
    ]));
    final c = db.context();
    for (final sql in [
      'DROP TABLE IF EXISTS studio_test_items, studio_test_big',
      'CREATE TABLE studio_test_items (id serial PRIMARY KEY, '
          'qty integer NOT NULL, '
          'created_at timestamptz NOT NULL DEFAULT now(), note text)',
      'CREATE TABLE studio_test_big (id integer)',
      'INSERT INTO studio_test_big SELECT generate_series(1, 10)',
      // Pretend the planner thinks it is huge; the real table has 10 rows.
      "UPDATE pg_class SET reltuples = 5000000 "
          "WHERE relname = 'studio_test_big'",
    ]) {
      await c.execute(sql);
    }
    final studio = GisilaStudio(db: db, allowUnauthenticated: true)
      ..register(_items)
      ..register(_big);
    final h = studio.handler(prefix: '/studio');
    handler = (r) => h(r);
  });

  tearDownAll(() async {
    if (skip != false) return;
    await db
        .context()
        .execute('DROP TABLE IF EXISTS studio_test_items, studio_test_big');
    await db.close();
  });

  Future<Response> get(String path) => Future.value(handler(Request(
      'GET', Uri.parse('http://localhost/studio$path'),
      handlerPath: '/studio/')));

  Future<Response> post(String path, String body) => Future.value(handler(
      Request('POST', Uri.parse('http://localhost/studio$path'),
          handlerPath: '/studio/',
          headers: {'content-type': 'application/x-www-form-urlencoded'},
          body: body)));

  Future<List<Map<String, dynamic>>> rows() async => [
        for (final r in await db
            .context()
            .execute('SELECT * FROM studio_test_items ORDER BY id'))
          r.toColumnMap(),
      ];

  test('page=0 and negative pages show the first page (ST-08)', () async {
    for (final p in ['0', '-3', 'x']) {
      expect((await get('/studio_test_items/?page=$p')).statusCode, 200,
          reason: p);
    }
  }, skip: skip);

  test('a large table shows its estimate instead of a full count (ST-08)',
      () async {
    final body = await (await get('/')).readAsString();
    expect(body, contains('5.0M'));
  }, skip: skip);

  test('bad input is rejected, not stored as NULL (ST-06)', () async {
    final res = await post('/studio_test_items/add/', 'qty=abc&note=x');
    expect(res.statusCode, 422);
    expect(await res.readAsString(), contains('Enter a whole number.'));
    expect(await rows(), isEmpty);
  }, skip: skip);

  test('a blank column with a default gets the default (ST-06)', () async {
    final res = await post('/studio_test_items/add/', 'qty=3&created_at=');
    expect(res.statusCode, 302);
    final row = (await rows()).single;
    expect(row['qty'], 3);
    expect(row['created_at'], isA<DateTime>());
    expect(row['note'], isNull);

    // Editing with the field blank keeps the stored value.
    final id = row['id'];
    final stamp = row['created_at'];
    await post('/studio_test_items/$id/change/', 'qty=4&created_at=');
    final after = (await rows()).single;
    expect(after['qty'], 4);
    expect(after['created_at'], stamp);
  }, skip: skip);

  test('a blank required field without a default is an error', () async {
    final res = await post('/studio_test_items/add/', 'qty=&note=y');
    expect(res.statusCode, 422);
    expect(await res.readAsString(), contains('This field is required.'));
  }, skip: skip);
}
