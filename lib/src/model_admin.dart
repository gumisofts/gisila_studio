/// Configuration for a single model registered in Gisila Studio.
library gisila_studio.model_admin;

import 'package:gisila_orm/gisila.dart';

/// Configuration controlling how a model appears and behaves in the admin.
///
/// ```dart
/// studio.register<User>(
///   UserTable.metadata,
///   displayName: 'User',
///   listDisplay: ['id', 'first_name', 'email'],
///   searchFields: ['first_name', 'email'],
///   readonlyFields: ['id', 'date_joined'],
///   ordering: ['-date_joined'],
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
  final List<String>? listDisplay;

  /// Columns to search via `ILIKE '%query%'`. Only string-like columns
  /// should be listed here.
  final List<String> searchFields;

  /// Columns shown on the edit form but locked (rendered as read-only text).
  final List<String> readonlyFields;

  /// Columns entirely excluded from add/change forms (still visible in list).
  final List<String> excludeFields;

  /// Number of rows per page in the list view.
  final int pageSize;

  /// Default ordering for the list view. Prefix with `-` for descending,
  /// e.g. `['-date_joined', 'email']`. Defaults to primary key ascending.
  final List<String> ordering;

  /// Sidebar group label, e.g. `"Catalog"`. Models without a group appear
  /// under `"General"`.
  final String? group;

  const ModelAdmin({
    required this.meta,
    required this.displayName,
    required this.displayNamePlural,
    this.listDisplay,
    this.searchFields = const [],
    this.readonlyFields = const [],
    this.excludeFields = const [],
    this.pageSize = 25,
    this.ordering = const [],
    this.group,
  });

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
