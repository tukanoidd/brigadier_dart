import 'package:brigadier_dart/src/arguments/argument_type.dart';
import 'package:brigadier_dart/src/context/command_context.dart';
import 'package:brigadier_dart/src/string_reader.dart';

enum StringType {
  SINGLE_WORD,
  QOUTABLE_PHRASE,
  GREEDY_PHRASE,
}

extension StringTypeExtension on StringType {
  Iterable<String> get examples {
    switch (this) {
      case StringType.SINGLE_WORD:
        return ['word', 'words_with_underscores'];
      case StringType.QOUTABLE_PHRASE:
        return ['\"quoted phrase\"', 'word', '\"\"'];
      case StringType.GREEDY_PHRASE:
        return ['word', 'words with spaces', '\"and symbols\"'];
    }
  }
}

class StringArgumentType extends ArgumentType<String> {
  final StringType _type;

  StringArgumentType._(final StringType type) : _type = type;

  static StringArgumentType word() =>
      StringArgumentType._(StringType.SINGLE_WORD);

  static StringArgumentType string() =>
      StringArgumentType._(StringType.QOUTABLE_PHRASE);

  static StringArgumentType greedyString() =>
      StringArgumentType._(StringType.GREEDY_PHRASE);

  static String getString(
    final CommandContext<dynamic> context,
    final String name,
  ) =>
      context.getArgument<String>(name);

  StringType get type => _type;

  @override
  String parse(StringReader reader) {
    if (type == StringType.GREEDY_PHRASE) {
      final text = reader.remaining;
      reader.cursor = reader.totalLength;

      return text;
    } else if (type == StringType.SINGLE_WORD) {
      return reader.readUnquotedString();
    } else {
      return reader.readString();
    }
  }

  @override
  String toString() => 'string()';

  @override
  Iterable<String> get examples => _type.examples;

  static String escapeIfRequired(final String input) {
    for (final c in input.split('')) {
      if (!StringReader.isAllowedInUnquotedString(c)) return escape(input);
    }

    return input;
  }

  static String escape(final String input) {
    final result = StringBuffer('"');

    for (var i = 0; i < input.length; i++) {
      final c = input[i];

      if (c == '\\' || c == '"') result.write('\\');
      result.write(c);
    }

    result.write('"');

    return result.toString();
  }
}
