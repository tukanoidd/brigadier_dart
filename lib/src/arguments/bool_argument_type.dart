import 'dart:core';

import 'package:brigadier_dart/src/context/command_context.dart';
import 'package:brigadier_dart/src/string_reader.dart';
import 'package:brigadier_dart/src/suggestion/suggestions.dart';
import 'package:brigadier_dart/src/suggestion/suggestions_builder.dart';

import 'argument_type.dart';

class BoolArgumentType implements ArgumentType<bool> {
  static final Iterable<String> _EXAMPLES = ['true', 'false'];

  BoolArgumentType();

  static bool getBool(
    final CommandContext<dynamic> context,
    final String name,
  ) =>
      context.getArgument<bool>(name);

  @override
  bool parse(final StringReader reader) => reader.readBool();

  @override
  Future<Suggestions> listSuggestions<K>(CommandContext<K> context, SuggestionsBuilder builder) {
    if ('true'.startsWith(builder.remainingLowerCase)) builder.suggest('true');
    if ('false'.startsWith(builder.remainingLowerCase)) builder.suggest('false');

    return builder.buildFuture();
  }

  @override
  Iterable<String> get examples => _EXAMPLES;
}
