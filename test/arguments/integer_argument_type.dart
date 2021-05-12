import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  group('parse', () {
    test('parse', () {
      final reader = StringReader('15');

      expect(IntegerArgumentType().parse(reader), equals(15));
      expect(reader.canRead(), equals(false));
    });

    test('parse_tooSmall', () {
      final reader = StringReader('-5');

      expect(
        () => IntegerArgumentType(0, 100).parse(reader),
        throwsA(
          (ex) =>
              ex is CommandSyntaxException &&
              ex.type ==
                  CommandSyntaxException.BUILT_IN_EXCEPTIONS.integerTooLow &&
              ex.cursor == 0,
        ),
      );
    });

    test('parse_tooBig', () {
      final reader = StringReader('5');

      expect(
        () => IntegerArgumentType(-100, 0).parse(reader),
        throwsA(
          (ex) =>
              ex is CommandSyntaxException &&
              ex.type ==
                  CommandSyntaxException.BUILT_IN_EXCEPTIONS.integerTooHigh &&
              ex.cursor == 0,
        ),
      );
    });
  });

  test('testEquals', () {
    expect(IntegerArgumentType(), equals(IntegerArgumentType()));
    expect(
      IntegerArgumentType(-100, 100),
      equals(IntegerArgumentType(-100, 100)),
    );
    expect(
      IntegerArgumentType(-100, 50),
      equals(IntegerArgumentType(-100, 50)),
    );
    expect(
      IntegerArgumentType(-50, 100),
      equals(IntegerArgumentType(-50, 100)),
    );
  });

  test('testToString', () {
    expect(IntegerArgumentType().toString(), equals('integer()'));
    expect(IntegerArgumentType(-100).toString(), equals('integer(-100)'));
    expect(
      IntegerArgumentType(-100, 100).toString(),
      equals('integer(-100, 100)'),
    );
    expect(
      IntegerArgumentType(IntHelper.intMinFinite, 100).toString(),
      equals('integer(${IntHelper.intMinFinite}, 100)'),
    );
  });
}
