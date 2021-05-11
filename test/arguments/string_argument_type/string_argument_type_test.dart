import 'package:test/test.dart';

import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'string_argument_type_test.mocks.dart';

@GenerateMocks([StringReader])
void main() {
  group('testParse', () {
    test('testParseWord', () {
      final reader = MockStringReader();

      when(reader.readUnquotedString()).thenReturn('hello');
      expect(StringArgumentType.word().parse(reader), equals('hello'));
      verify(reader.readUnquotedString());
    });

    test('testParseString', () {
      final reader = MockStringReader();

      when(reader.readString()).thenReturn('hello world');
      expect(StringArgumentType.string().parse(reader), equals('hello world'));
      verify(reader.readString());
    });

    test('testParseGreedyString', () {
      final reader = StringReader('Hello world! This is a test.');

      expect(
        StringArgumentType.greedyString().parse(reader),
        equals('Hello world! This is a test.'),
      );
      expect(reader.canRead(), equals(false));
    });
  });

  test('testToString', () {
    expect(StringArgumentType.string().toString(), equals('string()'));
  });

  group('testEscapeIfRequired', () {
    test('testEscapeIfRequired_notRequired', () {
      expect(StringArgumentType.escapeIfRequired('hello'), equals('hello'));
      expect(StringArgumentType.escapeIfRequired(''), equals(''));
    });

    test('testEscapeIfRequired_multipleWords', () {
      expect(StringArgumentType.escapeIfRequired('hello world'),
          equals('\"hello world\"'));
    });

    test('testEscapeIfRequired_quote', () {
      expect(StringArgumentType.escapeIfRequired('hello \"world\"!'),
          equals('\"hello \\\"world\\\"!\"'));
    });

    test('testEscapeIfRequired_escapes', () {
      expect(StringArgumentType.escapeIfRequired('\\'), equals('\"\\\\\"'));
    });

    test('testEscapeIfRequired_singleQuote', () {
      expect(StringArgumentType.escapeIfRequired('\"'), equals('\"\\\"\"'));
    });
  });
}
