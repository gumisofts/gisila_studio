/// Gisila Studio — web-based admin interface for gisila models.
///
/// Mount the studio alongside your existing Shelf app:
///
/// ```dart
/// import 'package:gisila_studio/gisila_studio.dart';
///
/// final studio = GisilaStudio(db: db, title: 'My App Admin');
///
/// studio.register<User>(
///   UserTable.metadata,
///   displayName: 'User',
///   listDisplay: ['id', 'first_name', 'email', 'date_joined'],
///   searchFields: ['first_name', 'last_name', 'email'],
///   readonlyFields: ['id', 'date_joined'],
/// );
///
/// // Mount at /studio (or any path)
/// router.mount('/studio', studio.handler(prefix: '/studio'));
/// ```
library gisila_studio;

export 'src/model_admin.dart';
export 'src/studio.dart';
