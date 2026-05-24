/// Configuration for a single model registered in Gisila Studio.
library gisila_studio.model_admin;

import 'package:gisila_orm/gisila.dart';

/// Configuration controlling how a model appears and behaves in the admin.
///
/// Field-name lists ([listDisplay], [searchFields], [readonlyFields],
/// [excludeFields], [ordering]) accept either the snake_case DB column
/// names (`'first_name'`, `'created_at'`) or the camelCase Dart field
/// names from the generated model (`'firstName'`, `'createdAt'`). Any
/// camelCase entry whose snake_case form matches a real column is
/// transparently rewritten to that column at construction time.
///
/// ```dart
/// studio.register<User>(
///   UserTable.metadata,
///   displayName: 'User',
///   listDisplay: ['id', 'firstName', 'email'],
///   searchFields: ['firstName', 'email'],
///   readonlyFields: ['id', 'createdAt'],
///   ordering: ['-createdAt'],
/// );
/// ```
class ModelAdmin<T> {
  /// The ORM metadata for the model.
  final TableMeta<T> meta;

  /// Human-readable singular name, e.g. `"User"`. Defaults to the table
  /// name with underscores replaced by spaces and title-cased.
  final String displayName;

  /// Human-readable plural name, e.g. `"Users"`. Defaults to
  /// `displayName + "s"`.
  final String displayNamePlural;

  /// Columns shown in the list view. `null` means all columns.
  /// Normalized to DB column names.
  final List<String>? listDisplay;

  /// Columns to search via `ILIKE '%query%'`. Only string-like columns
  /// should be listed here. Normalized to DB column names.
  final List<String> searchFields;

  /// Columns shown on the edit form but locked (rendered as read-only text).
  /// Normalized to DB column names.
  final List<String> readonlyFields;

  /// Columns entirely excluded from add/change forms (still visible in list).
  /// Normalized to DB column names.
  final List<String> excludeFields;

  /// Number of rows per page in the list view.
  final int pageSize;

  /// Default ordering for the list view. Prefix with `-` for descending,
  /// e.g. `['-created_at', 'email']`. Defaults to primary key ascending.
  /// Normalized to DB column names (direction prefix preserved).
  final List<String> ordering;

  /// Sidebar group label, e.g. `"Catalog"`. Models without a group appear
  /// under `"General"`.
  final String? group;

  ModelAdmin({
    required this.meta,
    required this.displayName,
    required this.displayNamePlural,
    List<String>? listDisplay,
    List<String> searchFields = const [],
    List<String> readonlyFields = const [],
    List<String> excludeFields = const [],
    this.pageSize = 25,
    List<String> ordering = const [],
    this.group,
  })  : listDisplay = listDisplay == null
            ? null
            : List.unmodifiable(
                listDisplay.map((c) => _resolveColumn(c, meta))),
        searchFields =
            List.unmodifiable(searchFields.map((c) => _resolveColumn(c, meta))),
        readonlyFields = List.unmodifiable(
            readonlyFields.map((c) => _resolveColumn(c, meta))),
        excludeFields = List.unmodifiable(
            excludeFields.map((c) => _resolveColumn(c, meta))),
        ordering = List.unmodifiable(ordering.map((t) {
          if (t.startsWith('-')) {
            return '-${_resolveColumn(t.substring(1), meta)}';
          }
          return _resolveColumn(t, meta);
        }));

  /// Columns visible in the list view (resolved, with defaults applied).
  List<String> get effectiveListDisplay =>
      listDisplay ?? meta.columnNames.take(6).toList();

  /// Order-by clauses for SQL, derived from [ordering] or falling back to
  /// the primary key.
  String get orderBySql {
    final terms = ordering.isNotEmpty ? ordering : [meta.primaryKey];
    return terms.map((t) {
      if (t.startsWith('-')) {
        return '"${t.substring(1)}" DESC';
      }
      return '"$t" ASC';
    }).join(', ');
  }

  /// Returns `true` if the column should appear on add/change forms.
  bool isEditable(String column) =>
      !readonlyFields.contains(column) && !excludeFields.contains(column);

  /// Returns `true` if the column should appear on forms at all
  /// (readonly or editable).
  bool isOnForm(String column) => !excludeFields.contains(column);
}

/// Factory helper to build a [ModelAdmin] with sensible defaults for names.
ModelAdmin<T> buildModelAdmin<T>(
  TableMeta<T> meta, {
  String? displayName,
  String? displayNamePlural,
  List<String>? listDisplay,
  List<String> searchFields = const [],
  List<String> readonlyFields = const [],
  List<String> excludeFields = const [],
  int pageSize = 25,
  List<String> ordering = const [],
  String? group,
}) {
  final name = displayName ?? _humanize(meta.tableName);
  return ModelAdmin<T>(
    meta: meta,
    displayName: name,
    displayNamePlural: displayNamePlural ?? '${name}s',
    listDisplay: listDisplay,
    searchFields: searchFields,
    readonlyFields: readonlyFields,
    excludeFields: excludeFields,
    pageSize: pageSize,
    ordering: ordering,
    group: group,
  );
}

String _humanize(String snake) => snake
    .split('_')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

/// Resolve a user-supplied column identifier to its actual DB column.
///
/// The ORM codegen maps schema columns like `created_at` to Dart fields
/// `createdAt`. Users naturally reach for the Dart name when configuring
/// the admin, so we accept either form: if [name] is already a known
/// column it is returned unchanged; if its camelCase → snake_case
/// transform matches a real column, that snake_case name is used;
/// otherwise [name] is returned as-is so the user gets a clear error
/// for genuine typos.
String _resolveColumn(String name, TableMeta meta) {
  if (meta.columnNames.contains(name)) return name;
  final snake = _camelToSnake(name);
  if (meta.columnNames.contains(snake)) return snake;
  return name;
}

String _camelToSnake(String s) => s
    .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
    .replaceFirst(RegExp(r'^_'), '');
