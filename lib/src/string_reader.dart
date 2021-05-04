import 'package:string_validator/string_validator.dart' as string_validator;

import 'exceptions/exceptions.dart';

import 'immutable_string_reader.dart';

class StringReader implements ImmutableStringReader {
  static const String _SYNTAX_ESCAPE = '\\';
  static const String _SYNTAX_DOUBLE_QUOTE = '"';
  static const String _SYNTAX_SINGLE_QUOTE = '\'';

  final String _string;
  int _cursor;

  StringReader.fromStringReader(final StringReader other)
      : _string = other._string,
        _cursor = other._cursor;

  StringReader(final String string)
      : _string = string,
        _cursor = 0;

  @override
  String get string => _string;

  @override
  int get remainingLength => _string.length - _cursor;

  @override
  int get totalLength => _string.length;

  @override
  // ignore: unnecessary_getters_setters
  int get cursor => _cursor;

  // ignore: unnecessary_getters_setters
  set cursor(final int newCursor) => _cursor = newCursor;

  @override
  String get read => _string.substring(0, _cursor);

  @override
  String get remaining => _string.substring(_cursor);

  @override
  bool canRead([final int? length]) =>
      _cursor + (length ?? 1) <= _string.length;

  @override
  String peek([final int? offset]) => _string[_cursor + (offset ?? 0)];

  String readAtCursor() => _string[_cursor++];

  void skip() => _cursor++;

  static bool isAllowedNumber(final String c) =>
      string_validator.isNumeric(c) || c == '.' || c == '-';

  static bool isQuotedStringStart(String c) =>
      c == _SYNTAX_DOUBLE_QUOTE || c == _SYNTAX_SINGLE_QUOTE;

  void skipWhitespace() {
    while (canRead() && peek().trim().isEmpty) {
      skip();
    }
  }

  int readInt() {
    final start = _cursor;

    while (canRead() && isAllowedNumber(peek())) {
      skip();
    }

    final number = string.substring(start, _cursor);

    if (number.isEmpty) {
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerExpectedInt
          .createWithContext(this);
    }

    var result = int.tryParse(number);
    if (result != null) {
      return result;
    } else {
      _cursor = start;
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerInvalidInt
          .createWithContext(this, number);
    }
  }

  double readDouble() {
    final start = _cursor;

    while (canRead() && isAllowedNumber(peek())) {
      skip();
    }

    final number = string.substring(start, _cursor);

    if (number.isEmpty) {
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerExpectedDouble
          .createWithContext(this);
    }

    var result = double.tryParse(number);
    if (result != null) {
      return double.parse(number);
    } else {
      _cursor = start;
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerInvalidDouble
          .createWithContext(this, number);
    }
  }

  static bool isAllowedInUnquotedString(final String c) {
    return string_validator.isAlphanumeric(c) ||
        c == '_' ||
        c == '-' ||
        c == '.' ||
        c == '+';
  }

  String readUnquotedString() {
    final start = _cursor;
    while (canRead() && isAllowedInUnquotedString(peek())) {
      skip();
    }

    return string.substring(start, _cursor);
  }

  String readQuotedString() {
    if (!canRead()) return '';

    final next = peek();
    if (!isQuotedStringStart(next)) {
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerExpectedStartOfQuote
          .createWithContext(this);
    }

    skip();

    return readStringUntil(next);
  }

  String readStringUntil(String terminator) {
    final result = StringBuffer();
    var escaped = false;

    while (canRead()) {
      final c = readAtCursor();

      if (escaped) {
        if (c == terminator || c == _SYNTAX_ESCAPE) {
          result.write(c);
          escaped = false;
        } else {
          cursor -= 1;
          throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
              .readerInvalidEscape
              .createWithContext(this, c.toString());
        }
      } else if (c == _SYNTAX_ESCAPE) {
        escaped = true;
      } else if (c == terminator) {
        return result.toString();
      } else {
        result.write(c);
      }
    }

    throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
        .readerExpectedEndOfQuote
        .createWithContext(this);
  }

  String readString() {
    if (!canRead()) {
      return '';
    }

    final next = peek();
    if (isQuotedStringStart(next)) {
      skip();
      return readStringUntil(next);
    }

    return readUnquotedString();
  }

  bool readBool() {
    final start = _cursor;
    final value = readString();

    if (value.isEmpty) {
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerExpectedBool
          .createWithContext(this);
    }

    if (value == 'true') {
      return true;
    } else if (value == 'false') {
      return false;
    } else {
      _cursor = start;
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerInvalidBool
          .createWithContext(this, value);
    }
  }

  void expect(final String c) {
    if (!canRead() || peek() != c) {
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS
          .readerExpectedSymbol
          .createWithContext(this, c.toString());
    }

    skip();
  }
}
