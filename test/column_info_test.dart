import 'package:gisila_studio/src/column_info.dart';
import 'package:test/test.dart';

ColumnInfo _col(String type, {bool nullable = false, String? def}) =>
    ColumnInfo(
        name: 'c', dataType: type, isNullable: nullable, columnDefault: def);

void main() {
  group('parseFormValue (ST-06)', () {
    test('parses valid values', () {
      expect(_col('integer').parseFormValue(' 42 '), 42);
      expect(_col('numeric').parseFormValue('1.5'), 1.5);
      expect(
          _col('timestamp with time zone').parseFormValue('2026-10-27T10:00'),
          DateTime(2026, 10, 27, 10));
      expect(_col('text').parseFormValue('hi'), 'hi');
    });

    test('rejects values that do not parse instead of storing NULL', () {
      for (final (type, raw) in [
        ('integer', 'abc'),
        ('bigint', '1.5'),
        ('double precision', 'x'),
        ('date', 'yesterday'),
      ]) {
        expect(() => _col(type, nullable: true).parseFormValue(raw),
            throwsFormatException,
            reason: '$type $raw');
      }
    });

    test('blank: NULL when nullable, the default when there is one', () {
      expect(_col('integer', nullable: true).parseFormValue(''), isNull);
      expect(_col('timestamp with time zone', def: 'now()').parseFormValue(''),
          same(ColumnInfo.useDefault));
      expect(_col('character varying').parseFormValue(''), '');
    });

    test('blank required non-text fields are an error, not 0 or now', () {
      expect(() => _col('integer').parseFormValue(''), throwsFormatException);
      expect(() => _col('timestamp with time zone').parseFormValue(null),
          throwsFormatException);
    });

    test('an unchecked checkbox is false', () {
      expect(_col('boolean').parseFormValue(null), isFalse);
      expect(_col('boolean').parseFormValue('on'), isTrue);
    });
  });
}
