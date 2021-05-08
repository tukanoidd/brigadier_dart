import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  group('canRead([int length])', () {
    test('canRead', () {
      final reader = StringReader('abc');

      expect(reader.canRead(), equals(true));
      reader.skip(); // 'a'
      expect(reader.canRead(), equals(true));
      reader.skip(); // 'b'
      expect(reader.canRead(), equals(true));
      reader.skip(); // 'c'
      expect(reader.canRead(), equals(false));
    });

    test('canRead_length', () {
      final reader = StringReader('abc');

      expect(reader.canRead(1), equals(true));
      expect(reader.canRead(2), equals(true));
      expect(reader.canRead(3), equals(true));
      expect(reader.canRead(4), equals(false));
      expect(reader.canRead(5), equals(false));
    });
  });

  test('getRemainingLength', () {
    final reader = StringReader('abc');

    expect(reader.remainingLength, equals(3));
    reader.cursor = 1;
    expect(reader.remainingLength, equals(2));
    reader.cursor = 2;
    expect(reader.remainingLength, equals(1));
    reader.cursor = 3;
    expect(reader.remainingLength, equals(0));
  });

  group('peek([int length])', () {
    test('peek', () {
      final reader = StringReader('abc');

      expect(reader.peek(), equals('a'));
      expect(reader.cursor, equals(0));
      reader.cursor = 2;
      expect(reader.peek(), equals('c'));
      expect(reader.cursor, equals(2));
    });

    test('peek_length', () {
      final reader = StringReader('abc');

      expect(reader.peek(0), equals('a'));
      expect(reader.peek(2), equals('c'));
      expect(reader.cursor, equals(0));
      reader.cursor = 1;
      expect(reader.peek(1), equals('c'));
      expect(reader.cursor, equals(1));
    });
  });

  test('readAtCursor', () {
    final reader = StringReader('abc');

    expect(reader.readAtCursor(), equals('a'));
    expect(reader.readAtCursor(), equals('b'));
    expect(reader.readAtCursor(), equals('c'));
    expect(reader.cursor, equals(3));
  });

  test('skip', () {
    final reader = StringReader('abc');

    reader.skip();
    expect(reader.cursor, equals(1));
  });

  test('remaining', () {
    final reader = StringReader('Hello!');

    expect(reader.remaining, equals('Hello!'));
    reader.cursor = 3;
    expect(reader.remaining, equals('lo!'));
    reader.cursor = 6;
    expect(reader.remaining, equals(''));
  });

  test('read', () {
    final reader = StringReader('Hello!');

    expect(reader.read, equals(''));
    reader.cursor = 3;
    expect(reader.read, equals('Hel'));
    reader.cursor = 6;
    expect(reader.read, equals('Hello!'));
  });

  group('skipWhitespace', () {
    test('skipWhitespace_none', () {
      final reader = StringReader('Hello!');

      reader.skipWhitespace();
      expect(reader.cursor, equals(0));
    });

    test('skipWhitespace_mixed', () {
      final reader = StringReader(' \t \t\nHello!');

      reader.skipWhitespace();
      expect(reader.cursor, equals(5));
    });

    test('skipWhitespace_empty', () {
      final reader = StringReader('');

      reader.skipWhitespace();
      expect(reader.cursor, equals(0));
    });
  });

  group('readUnquotedString', () {
    test('readUnquotedString', () {
      final reader = StringReader('hello world');

      expect(reader.readUnquotedString(), equals('hello'));
      expect(reader.read, equals('hello'));
      expect(reader.remaining, equals(' world'));
    });

    test('readUnquotedString_empty', () {
      final reader = StringReader('');

      expect(reader.readUnquotedString(), equals(''));
      expect(reader.read, equals(''));
      expect(reader.remaining, equals(''));
    });

    test('readUnquotedString_empty_withRemaining', () {
      final reader = StringReader(' hello world');

      expect(reader.readUnquotedString(), equals(''));
      expect(reader.read, equals(''));
      expect(reader.remaining, equals(' hello world'));
    });
  });

  group('readQuotedString', () {
    test('readQuotedString', () {
      final reader = StringReader('\"hello world\"');

      expect(reader.readQuotedString(), equals('hello world'));
      expect(reader.read, equals('\"hello world\"'));
      expect(reader.remaining, equals(''));
    });

    test('readSingleQuotedString', () {
      final reader = StringReader("'hello world'");

      expect(reader.readQuotedString(), equals('hello world'));
      expect(reader.read, equals("'hello world'"));
      expect(reader.remaining, equals(''));
    });

    test('readMixedQuotedString_doubleInsideSingle', () {
      final reader = StringReader("'hello \"world\"'");

      expect(reader.readQuotedString(), equals('hello \"world\"'));
      expect(reader.read, equals("'hello \"world\"'"));
      expect(reader.remaining, equals(''));
    });

    test('readMixedQuotedString_singleInsideDouble', () {
      final reader = StringReader("\"hello 'world'\"");

      expect(reader.readQuotedString(), equals("hello 'world'"));
      expect(reader.read, equals("\"hello 'world'\""));
      expect(reader.remaining, equals(''));
    });

    test('readQuotedString_empty', () {
      final reader = StringReader('');

      expect(reader.readQuotedString(), equals(''));
      expect(reader.read, equals(''));
      expect(reader.remaining, equals(''));
    });

    test('readQuotedString_emptyQuoted', () {
      final reader = StringReader('\"\"');

      expect(reader.readQuotedString(), equals(''));
      expect(reader.read, equals('\"\"'));
      expect(reader.remaining, equals(''));
    });

    test('readQuotedString_emptyQuoted_withRemaining', () {
      final reader = StringReader('\"\" hello world');

      expect(reader.readQuotedString(), equals(''));
      expect(reader.read, equals('\"\"'));
      expect(reader.remaining, equals(' hello world'));
    });

    test('readQuotedString_withEscapedQuote', () {
      final reader = StringReader('\"hello \\\"world\\\"\"');

      expect(reader.readQuotedString(), equals('hello \"world\"'));
      expect(reader.read, equals('\"hello \\\"world\\\"\"'));
      expect(reader.remaining, equals(''));
    });

    test('readQuotedString_withEscapedEscapes', () {
      final reader = StringReader('\"\\\\o/\"');

      expect(reader.readQuotedString(), equals('\\o/'));
      expect(reader.read, equals('\"\\\\o/\"'));
      expect(reader.remaining, equals(''));
    });

    test('readQuotedString_withRemaining', () {
      final reader = StringReader('\"hello world\" foo bar');

      expect(reader.readQuotedString(), equals('hello world'));
      expect(reader.read, equals('\"hello world\"'));
      expect(reader.remaining, equals(' foo bar'));
    });

    test('readQuotedString_withImmediateRemaining', () {
      final reader = StringReader('\"hello world\"foo bar');

      expect(reader.readQuotedString(), equals('hello world'));
      expect(reader.read, equals('\"hello world\"'));
      expect(reader.remaining, equals('foo bar'));
    });

    test('readQuotedString_noOpen', () {
      try {
        StringReader('hello world\"').readQuotedString();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.readerExpectedStartOfQuote));
        expect(ex.cursor, equals(0));
      }
    });

    test('readQuotedString_noClose', () {
      try {
        StringReader('\"hello world').readQuotedString();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.readerExpectedEndOfQuote));
        expect(ex.cursor, equals(12));
      }
    });

    test('readQuotedString_invalidEscape', () {
      try {
        StringReader('\"hello\\nworld\"').readQuotedString();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.readerInvalidEscape));
        expect(ex.cursor, equals(7));
      }
    });

    test('readQuotedString_invalidQuoteEscape', () {
      try {
        StringReader("'hello\\\"\'world").readQuotedString();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.readerInvalidEscape));
        expect(ex.cursor, equals(7));
      }
    });
  });

  group('readString', () {
    test('readString_noQuotes', () {
      final reader = StringReader('hello world');

      expect(reader.readString(), equals('hello'));
      expect(reader.read, equals('hello'));
      expect(reader.remaining, equals(' world'));
    });

    test('readString_singleQuotes', () {
      final reader = StringReader("'hello world'");

      expect(reader.readString(), equals('hello world'));
      expect(reader.read, equals("'hello world'"));
      expect(reader.remaining, equals(''));
    });

    test('readString_doubleQuotes', () {
      final reader = StringReader('\"hello world\"');

      expect(reader.readString(), equals('hello world'));
      expect(reader.read, equals('\"hello world\"'));
      expect(reader.remaining, equals(''));
    });
  });

  group('readInt', () {
    test('readInt', () {
      final reader = StringReader('1234567890');

      expect(reader.readInt(), equals(1234567890));
      expect(reader.read, equals('1234567890'));
      expect(reader.remaining, equals(''));
    });

    test('readInt_negative', () {
      final reader = StringReader('-1234567890');

      expect(reader.readInt(), equals(-1234567890));
      expect(reader.read, equals('-1234567890'));
      expect(reader.remaining, equals(''));
    });

    test('readInt_invalid', () {
      try {
        StringReader('12.34').readInt();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(
                CommandSyntaxException.BUILT_IN_EXCEPTIONS.readerInvalidInt));
        expect(ex.cursor, equals(0));
      }
    });

    test('readInt_none', () {
      try {
        StringReader('').readInt();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(
                CommandSyntaxException.BUILT_IN_EXCEPTIONS.readerExpectedInt));
        expect(ex.cursor, equals(0));
      }
    });

    test('readInt_withRemaining', () {
      final reader = StringReader('1234567890 foo bar');

      expect(reader.readInt(), equals(1234567890));
      expect(reader.read, equals('1234567890'));
      expect(reader.remaining, equals(' foo bar'));
    });

    test('readInt_withRemainingImmediate', () {
      final reader = StringReader('1234567890foo bar');

      expect(reader.readInt(), equals(1234567890));
      expect(reader.read, equals('1234567890'));
      expect(reader.remaining, equals('foo bar'));
    });
  });

  group('readDouble', () {
    test('readDouble', () {
      final reader = StringReader('123');

      expect(reader.readDouble(), equals(123.0));
      expect(reader.read, equals('123'));
      expect(reader.remaining, equals(''));
    });

    test('readDouble_withDecimal', () {
      final reader = StringReader('12.34');

      expect(reader.readDouble(), equals(12.34));
      expect(reader.read, equals('12.34'));
      expect(reader.remaining, equals(''));
    });

    test('readDouble_negative', () {
      final reader = StringReader('-123');

      expect(reader.readDouble(), equals(-123.0));
      expect(reader.read, equals('-123'));
      expect(reader.remaining, equals(''));
    });

    test('readDouble_invalid', () {
      try {
        StringReader('12.34.56').readDouble();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.readerInvalidDouble));
        expect(ex.cursor, equals(0));
      }
    });

    test('readDouble_none', () {
      try {
        StringReader('').readDouble();
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.readerExpectedDouble));
        expect(ex.cursor, equals(0));
      }
    });

    test('readDouble_withRemaining', () {
      final reader = StringReader('12.34 foo bar');

      expect(reader.readDouble(), equals(12.34));
      expect(reader.read, equals('12.34'));
      expect(reader.remaining, equals(' foo bar'));
    });

    test('readDouble_withRemainingImmediate', () {
      final reader = StringReader('12.34foo bar');

      expect(reader.readDouble(), equals(12.34));
      expect(reader.read, equals('12.34'));
      expect(reader.remaining, equals('foo bar'));
    });
  });

  group('expect', () {
    test('expect_correct', () {
      final reader = StringReader('abc');

      reader.expect('a');
      expect(reader.cursor, equals(1));
    });

    test(
      'expect_incorrect',
      () {
        final reader = StringReader('bcd');

        try {
          reader.expect('a');
          fail('Didn\'t pass {expect_incorrect test}');
        } on CommandSyntaxException catch (ex) {
          expect(
              ex.type,
              equals(CommandSyntaxException
                  .BUILT_IN_EXCEPTIONS.readerExpectedSymbol));
          expect(ex.cursor, equals(0));
        }
      },
    );

    test('expect_none', () {
      final reader = StringReader('');

      try {
        reader.expect('a');
        fail('Didn\'t pass {expect_none test}');
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.readerExpectedSymbol));
        expect(ex.cursor, equals(0));
      }
    });
  });

  group('readBool', () {
    test('readBool_correct', () {
      final reader = StringReader('true');

      expect(reader.readBool(), equals(true));
      expect(reader.read, equals('true'));
    });

    test('readBool_incorrect', () {
      final reader = StringReader('tuesday');

      try {
        reader.readBool();
        fail('Didn\'t pass {readBool_incorrect test}');
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(
                CommandSyntaxException.BUILT_IN_EXCEPTIONS.readerInvalidBool));
        expect(ex.cursor, equals(0));
      }
    });

    test('readBool_none', () {
      final reader = StringReader('');

      try {
        reader.readBool();
        fail('Didn\'t pass {readBool_none test}');
      } on CommandSyntaxException catch (ex) {
        expect(
            ex.type,
            equals(
                CommandSyntaxException.BUILT_IN_EXCEPTIONS.readerExpectedBool));
        expect(ex.cursor, equals(0));
      }
    });
  });
}
