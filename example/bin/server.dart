/// Gisila Studio example server.
///
/// Run:
///   dart pub get
///   dart run bin/server.dart
///
/// Then open http://localhost:8080/studio/
///
/// Configure your database in DATABASE_URL or database.yaml.
import 'dart:io';

import 'package:gisila_orm/gisila.dart';
import 'package:gisila_studio/gisila_studio.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Import the generated models from your .gisila.yaml schema.
import '../lib/models/blog.gisila.g.dart';

Future<void> main() async {
  // ── Database connection ────────────────────────────────────────────
  //
  // Option 1: Use a database.yaml in the current directory.
  // Option 2: Set DATABASE_URL environment variable.
  //
  // Example database.yaml:
  //   default: blog
  //   connections:
  //     blog:
  //       type: postgresql
  //       host: localhost
  //       port: 5432
  //       database: blog_dev
  //       username: postgres
  //       password: postgres

  final db = await Database.connect(
    await DatabaseConfig.fromFile('database.yaml'),
  );

  // ── Studio setup ───────────────────────────────────────────────────

  final studio = GisilaStudio(db: db, title: 'Blog Admin');

  studio.register<User>(
    UserTable.metadata,
    displayName: 'User',
    displayNamePlural: 'Users',
    listDisplay: ['id', 'first_name', 'last_name', 'email', 'date_joined'],
    searchFields: ['first_name', 'last_name', 'email'],
    readonlyFields: ['id', 'date_joined'],
    ordering: ['-date_joined'],
  );

  studio.register<Author>(
    AuthorTable.metadata,
    displayName: 'Author',
    displayNamePlural: 'Authors',
    listDisplay: ['id', 'first_name', 'last_name', 'email'],
    searchFields: ['first_name', 'last_name', 'email'],
    readonlyFields: ['id'],
  );

  studio.register<Book>(
    BookTable.metadata,
    displayName: 'Book',
    displayNamePlural: 'Books',
    listDisplay: ['title', 'subtitle', 'author_id', 'published_date', 'page_count'],
    searchFields: ['title', 'subtitle', 'isbn'],
    ordering: ['-published_date'],
  );

  studio.register<Review>(
    ReviewTable.metadata,
    displayName: 'Review',
    displayNamePlural: 'Reviews',
    listDisplay: ['id', 'book_id', 'reviewer_id', 'rating', 'review_date', 'is_approved'],
    searchFields: ['review_text'],
    readonlyFields: ['id'],
    ordering: ['-review_date'],
  );

  // ── Shelf router ───────────────────────────────────────────────────

  final router = Router();

  // Redirect root to studio
  router.get('/', (_) => Response.found('/studio/'));

  // Mount the studio at /studio
  router.mount('/studio', studio.handler(prefix: '/studio'));

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  // ── Start server ───────────────────────────────────────────────────

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await io.serve(pipeline, '0.0.0.0', port);
  print('Gisila Studio running at http://localhost:${server.port}/studio/');
}
