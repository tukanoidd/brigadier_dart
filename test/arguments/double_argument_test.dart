import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  group('parse', () {
    test('parse', () {
      final reader = StringReader('15');

      expect(DoubleArgumentType(0, 100).parse(reader), equals(15.0));
      expect(reader.canRead(), equals(false));
    });

    test('parse_tooSmall', () {
      final reader = StringReader('-5');

      expect(
        () {
          DoubleArgumentType(0, 100).parse(reader);
          fail('Parsed number that it shouldn\'t have');
        },
        throwsA(
          (ex) =>
              ex is CommandSyntaxException &&
              ex.type ==
                  CommandSyntaxException.BUILT_IN_EXCEPTIONS.doubleTooLow &&
              ex.cursor == 0,
        ),
      );
    });

    test('parse_tooBig', () {
      final reader = StringReader('5');

      expect(
        () {
          DoubleArgumentType(-100, 0).parse(reader);
          fail('Parse number that it shouldn\'t have');
        },
        throwsA(
          (ex) =>
              ex is CommandSyntaxException &&
              ex.type ==
                  CommandSyntaxException.BUILT_IN_EXCEPTIONS.doubleTooHigh &&
              ex.cursor == 0,
        ),
      );
    });
  });

  test('testEquals', () {
    expect(
      DoubleArgumentType(),
      equals(DoubleArgumentType()),
    );
    expect(
      DoubleArgumentType(-100, 100),
      equals(DoubleArgumentType(-100, 100)),
    );
    expect(
      DoubleArgumentType(-100, 50),
      equals(DoubleArgumentType(-100, 50)),
    );
    expect(
      DoubleArgumentType(-50, 100),
      equals(DoubleArgumentType(-50, 100)),
    );
  });

  test('testToString', () {
    expect(DoubleArgumentType().toString(), equals('double()'));
    expect(
      DoubleArgumentType(-100).toString(),
      equals('double(-100.0)'),
    );
    expect(
      DoubleArgumentType(-100, 100).toString(),
      equals('double(-100.0, 100.0)'),
    );
    expect(
      DoubleArgumentType(-double.maxFinite, 100.0).toString(),
      equals('double(${-double.maxFinite}, 100.0)'),
    );
  });
}
