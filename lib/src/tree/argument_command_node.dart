import 'package:brigadier_dart/src/arguments/argument_type.dart';
import 'package:brigadier_dart/src/builder/builder.dart';
import 'package:brigadier_dart/src/command.dart';
import 'package:brigadier_dart/src/context/command_context_builder.dart';
import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/helpers.dart';
import 'package:brigadier_dart/src/redirect_modifier.dart';
import 'package:brigadier_dart/src/string_reader.dart';
import 'package:brigadier_dart/src/suggestion/all.dart';

import 'command_node.dart';

class ArgumentCommandNode<T, K> extends CommandNode<T> {
  static final String USAGE_ARGUMENT_OPEN = '<';
  static final String USAGE_ARGUMENT_CLOSE = '>';

  final String _name;
  final ArgumentType<K> _type;
  final SuggestionProvider<T>? _customSuggestions;

  ArgumentCommandNode(
    final String name,
    final ArgumentType<K> type,
    final Command<T>? command,
    final Predicate<T> requirement,
    final CommandNode<T>? redirect,
    final RedirectModifier<T>? modifier,
    final bool forks,
    final SuggestionProvider<T>? customSuggestions,
  )   : _name = name,
        _type = type,
        _customSuggestions = customSuggestions,
        super(command, requirement, redirect, modifier, forks);

  ArgumentType<K> get type => _type;

  @override
  String get name => _name;

  @override
  String get usageText => '$USAGE_ARGUMENT_OPEN$_name$USAGE_ARGUMENT_CLOSE';

  SuggestionProvider<T>? get customSuggestionProvider => _customSuggestions;

  @override
  void parse(
    final StringReader reader,
    final CommandContextBuilder<T> contextBuilder,
  ) {
    final start = reader.cursor;
    final result = _type.parse(reader);
    final parsed = ParsedArgument<T, K>(start, reader.cursor, result);

    contextBuilder.withArgument(name, parsed);
    contextBuilder.withNode(this, parsed.range);
  }

  @override
  Future<Suggestions> listSuggestions(
    final CommandContext<T> context,
    final SuggestionsBuilder builder,
  ) {
    if (_customSuggestions == null) {
      return _type.listSuggestions(context, builder);
    }

    return _customSuggestions!.getSuggestions(context, builder);
  }

  @override
  RequiredArgumentBuilder<T, K> createBuilder() {
    final builder = RequiredArgumentBuilder<T, K>(_name, _type);

    builder.requires(requirement);
    builder.forward(redirect, redirectModifier, isFork);
    builder.suggests(_customSuggestions);

    if (command != null) builder.executes(command!);

    return builder;
  }

  @override
  bool isValidInput(final String input) {
    try {
      final reader = StringReader(input);
      type.parse(reader);

      return !reader.canRead() || reader.peek() == '';
    } catch (ex) {
      return false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (super == other) return true;
    if (!(other is ArgumentCommandNode)) return false;

    if (_name != other._name) return false;
    if (_type != other._type) return false;

    return super == other;
  }

  @override
  int get hashCode => 31 * _name.hashCode + _type.hashCode;

  @override
  String get sortedKey => _name;

  @override
  Iterable<String> get examples => _type.examples;

  @override
  String toString() => '<argument $_name:$_type>';
}
