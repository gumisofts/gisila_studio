/// Database schema introspection for Gisila Studio.
///
/// Queries `information_schema.columns` once per table and caches the result
/// so subsequent requests are instant.
library gisila_studio.column_info;

import 'package:gisila_orm/gisila.dart';

/// Metadata about a single column derived from the database schema.
class ColumnInfo {
  final String name;

  /// Postgres data type, e.g. `"integer"`, `"character varying"`, `"boolean"`.
  final String dataType;

  final bool isNullable;
  final String? columnDefault;

  const ColumnInfo({
    required this.name,
    required this.dataType,
    required this.isNullable,
    this.columnDefault,
  });

  /// The HTML input type appropriate for this column.
  String get inputType {
    switch (dataType) {
      case 'integer':
      case 'bigint':
      case 'smallint':
      case 'serial':
      case 'bigserial':
        return 'number';
      case 'real':
      case 'double precision':
      case 'numeric':
      case 'decimal':
        return 'number_decimal';
      case 'boolean':
        return 'checkbox';
      case 'date':
        return 'date';
      case 'time without time zone':
      case 'time with time zone':
        return 'time';
      case 'timestamp without time zone':
      case 'timestamp with time zone':
        return 'datetime-local';
      case 'json':
      case 'jsonb':
      case 'text':
        return 'textarea';
      default:
        return 'text';
    }
  }

  /// Convert a raw form string value to the Dart/Postgres type for this column.
  Object? parseFormValue(String? raw) {
    if (raw == null || raw.isEmpty) return isNullable ? null : _defaultFor();
    switch (dataType) {
      case 'integer':
      case 'bigint':
      case 'smallint':
      case 'serial':
      case 'bigserial':
        return int.tryParse(raw);
      case 'real':
      case 'double precision':
      case 'numeric':
      case 'decimal':
        return double.tryParse(raw);
      case 'boolean':
        return raw == 'on' || raw == 'true' || raw == '1';
      case 'date':
        return DateTime.tryParse(raw);
      case 'timestamp without time zone':
      case 'timestamp with time zone':
        return DateTime.tryParse(raw);
      default:
        return raw;
    }
  }

  Object? _defaultFor() {
    switch (dataType) {
      case 'integer':
      case 'bigint':
      case 'smallint':
        return 0;
      case 'real':
      case 'double precision':
      case 'numeric':
        return 0.0;
      case 'boolean':
        return false;
      default:
        return '';
    }
  }

  /// Format a raw DB value for display in the admin list/form.
  String display(Object? value) {
    if (value == null) return '—';
    if (value is DateTime) {
      return value.toIso8601String().replaceFirst('T', ' ').split('.').first;
    }
    if (value is bool) return value ? '✓' : '✗';
    final str = value.toString();
    if (str.length > 80) return '${str.substring(0, 77)}…';
    return str;
  }

  /// Format a raw DB value as an HTML form field pre-fill value.
  String formValue(Object? value) {
    if (value == null) return '';
    if (value is DateTime) {
      if (dataType == 'date') {
        return '${value.year.toString().padLeft(4, '0')}-'
            '${value.month.toString().padLeft(2, '0')}-'
            '${value.day.toString().padLeft(2, '0')}';
      }
      return '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}T'
          '${value.hour.toString().padLeft(2, '0')}:'
          '${value.minute.toString().padLeft(2, '0')}:'
          '${value.second.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }
}

/// In-memory cache: tableName → ordered list of [ColumnInfo].
final Map<String, List<ColumnInfo>> _columnCache = {};

/// Fetch column metadata for [tableName], using [db] for the first call.
/// Results are cached for the process lifetime.
Future<List<ColumnInfo>> fetchColumnInfo(String tableName, DbContext db) async {
  if (_columnCache.containsKey(tableName)) return _columnCache[tableName]!;

  const sql = '''
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = \$1
ORDER BY ordinal_position
''';

  final result = await db.execute(sql, parameters: [tableName]);
  final columns = result.map((row) {
    final m = row.toColumnMap();
    return ColumnInfo(
      name: m['column_name'] as String,
      dataType: m['data_type'] as String,
      isNullable: (m['is_nullable'] as String) == 'YES',
      columnDefault: m['column_default'] as String?,
    );
  }).toList();

  _columnCache[tableName] = columns;
  return columns;
}

/// Invalidate the column cache (useful in tests).
void clearColumnCache() => _columnCache.clear();
