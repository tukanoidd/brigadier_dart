import 'package:brigadier_dart/src/builder/literal_argument_builder.dart';
import 'package:brigadier_dart/src/command.dart';
import 'package:brigadier_dart/src/context/command_context_builder.dart';
import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/exceptions/exceptions.dart';
import 'package:brigadier_dart/src/helpers.dart';
import 'package:brigadier_dart/src/redirect_modifier.dart';
import 'package:brigadier_dart/src/string_reader.dart';
import 'package:brigadier_dart/src/suggestion/all.dart';
import 'package:brigadier_dart/src/tree/tree.dart';

import 'command_node.dart';

class LiteralCommandNode<T> extends CommandNode<T> {
  final String _literal;
  final String _literalLowerCase;

  LiteralCommandNode(
    final String literal,
    final Command<T> command,
    final Predicate<T> requirement,
    final CommandNode<T>? redirect,
    final RedirectModifier<T>? modifier,
    final bool forks,
  )   : _literal = literal,
        _literalLowerCase = literal.toLowerCase(),
        super(
          command,
          requirement,
          redirect,
          modifier,
          forks,
        );

  String get literal => _literal;

  @override
  String get name => _literal;

  @override
  void parse(final StringReader reader, final CommandContextBuilder<T> contextBuilder) {
    final start = reader.cursor;

    final end = _parse(reader);

    if (end > -1) {
      contextBuilder.withNode(this, StringRange.between(start, end));
      return;
    }

    throw CommandSyntaxException.BUILT_IN_EXCEPTIONS.literalIncorrect.createWithContext(reader, _literal);
  }

  int _parse(final StringReader reader) {
    final start = reader.cursor;

    if (reader.canRead(_literal.length)) {
      final end = start + _literal.length;

      if (reader.string.substring(start, end) == _literal) {
        reader.cursor = end;
        if (!reader.canRead() || reader.peek() == '') {
          return end;
        } else {
          reader.cursor = start;
        }
      }
    }

    return -1;
  }

  @override
  Future<Suggestions> listSuggestions(final CommandContext<T> context, final SuggestionsBuilder builder) {
    if (_literalLowerCase.startsWith(builder.remainingLowerCase)) {
      return builder.suggest(_literal).buildFuture();
    } else {
      return Suggestions.empty;
    }
  }

  @override
  bool isValidInput(String input) => _parse(StringReader(input)) > -1;

  @override
  bool operator ==(Object other) {
    if (this == other) return true;
    if (!(other is LiteralCommandNode)) return false;

    if (_literal != other._literal) return false;

    return super == other;
  }

  @override
  String get usageText => _literal;

  @override
  int get hashCode => 31 * _literal.hashCode + super.hashCode;

  @override
  LiteralArgumentBuilder<T> createBuilder() {
    final builder = LiteralArgumentBuilder.literal<T>(_literal);
    builder.requires(requirement);
    builder.forward(redirect, redirectModifier, isFork);

    if (command != null) builder.executes(command!);

    return builder;
  }

  @override
  String get sortedKey => _literal;

  @override
  Iterable<String> get examples => Set.unmodifiable([_literal]);

  @override
  String toString() => '<literal $_literal>';
}
