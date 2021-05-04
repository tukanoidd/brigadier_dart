import 'package:brigadier_dart/src/builder/argument_builder.dart';
import 'package:brigadier_dart/src/string_reader.dart';

import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/suggestion/suggestions.dart';
import 'package:brigadier_dart/src/suggestion/suggestions_builder.dart';

import 'command_node.dart';

class RootCommandNode<T> extends CommandNode<T> {
  RootCommandNode()
      : super(
          null,
          (c) => true,
          null,
          (s) => Set.unmodifiable([s.source]),
          false,
        );

  @override
  String get name => '';

  @override
  String get usageText => '';

  @override
  void parse(final StringReader reader,
      final CommandContextBuilder<T> contextBuilder) {}

  @override
  Future<Suggestions> listSuggestions(
          CommandContext<T> context, SuggestionsBuilder builder) =>
      Suggestions.empty;

  @override
  bool isValidInput(String input) => false;

  @override
  bool operator ==(Object other) {
    if (this == other) return true;
    if (!(other is RootCommandNode)) return false;

    return super == other;
  }

  @override
  ArgumentBuilder<T, dynamic> createBuilder() =>
      throw Exception('Cannot convert root into a builder');

  @override
  String get sortedKey => '';

  @override
  Iterable<String> get examples => Iterable.empty();

  @override
  String toString() => '<root>';
}
