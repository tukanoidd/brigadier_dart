import 'package:brigadier_dart/src/builder/argument_builder.dart';
import 'package:meta/meta.dart';

import 'package:brigadier_dart/src/ambiguity_consumer.dart';
import 'package:brigadier_dart/src/string_reader.dart';
import 'package:brigadier_dart/src/command.dart';
import 'package:brigadier_dart/src/redirect_modifier.dart';
import 'package:brigadier_dart/src/helpers.dart';

import 'package:brigadier_dart/src/suggestion/all.dart';
import 'package:brigadier_dart/src/context/context.dart';

import 'literal_command_node.dart';
import 'argument_command_node.dart';
import 'root_command_node.dart';

abstract class CommandNode<T> implements Comparable<CommandNode<T>> {
  final Map<String, CommandNode<T>> _children = {};
  final Map<String, LiteralCommandNode<T>> _literals = {};
  final Map<String, ArgumentCommandNode<T, dynamic>> _arguments = {};
  final Predicate<T> _requirement;
  final CommandNode<T>? _redirect;
  final RedirectModifier<T>? _modifier;
  final bool _forks;
  Command<T>? _command;

  @protected
  CommandNode(
    final Command<T>? command,
    final Predicate<T> requirement,
    final CommandNode<T>? redirect,
    final RedirectModifier<T>? modifier,
    final bool forks,
  )   : _command = command,
        _requirement = requirement,
        _redirect = redirect,
        _modifier = modifier,
        _forks = forks;

  Command<T>? get command => _command;

  Iterable<CommandNode<T>> get children => _children.values;

  CommandNode<T>? getChild(final String name) => _children[name];

  CommandNode<T>? get redirect => _redirect;

  RedirectModifier<T>? get redirectModifier => _modifier;

  bool canUse(final T source) => _requirement(source);

  void addChild(final CommandNode<T> node) {
    if (node is RootCommandNode) {
      throw Exception(
          'Cannot add a RootCommandNode as a child to any other CommandNode');
    }

    final child = _children[node.name];
    if (child != null) {
      // We've found something to merge onto
      if (node._command != null) child._command = node._command;

      for (final grandChild in node.children) {
        child.addChild(grandChild);
      }
    } else {
      _children[node.name] = node;

      if (node is LiteralCommandNode) {
        _literals[node.name] = node as LiteralCommandNode<T>;
      } else if (node is ArgumentCommandNode) {
        _arguments[node.name] = node as ArgumentCommandNode<T, dynamic>;
      }
    }
  }

  void findAmbiguities(final AmbiguityConsumer<T> consumer) {
    var matches = <String>{};

    for (final child in _children.values) {
      for (final sibling in _children.values) {
        if (child == sibling) continue;

        for (final input in child.examples) {
          if (sibling.isValidInput(input)) matches.add(input);
        }

        if (matches.isNotEmpty) {
          consumer.ambiguous(this, child, sibling, matches);
          matches = <String>{};
        }
      }

      child.findAmbiguities(consumer);
    }
  }

  @protected
  bool isValidInput(final String input);

  @override
  bool operator ==(Object other) {
    if (this == other) return true;
    if (!(other is CommandNode)) return false;

    if (_children != other._children) return false;
    if (_command != null
        ? (_command != other._command)
        : (other._command != null)) return false;

    return true;
  }

  @override
  int get hashCode =>
      31 * _children.hashCode + (_command != null ? _command.hashCode : 0);

  Predicate<T> get requirement => _requirement;

  String get name;

  String get usageText;

  void parse(StringReader reader, CommandContextBuilder<T> contextBuilder);

  Future<Suggestions> listSuggestions(CommandContext<T> context, SuggestionsBuilder builder);

  ArgumentBuilder<T, dynamic> createBuilder();

  String get sortedKey;

  Iterable getRelevantNodes(final StringReader input) {
    if (_literals.isNotEmpty) {
      final cursor = input.cursor;
      while(input.canRead() && input.peek() != ' ') {
        input.skip();
      }

      final text = input.string.substring(cursor, input.cursor);
      input.cursor = cursor;

      final literal = _literals[text];

      if (literal != null) {
        return Set.unmodifiable([literal]);
      } else {
        return _arguments.values;
      }
    } else {
      return _arguments.values;
    }
  }

  @override
  int compareTo(CommandNode<T> other) {
    if ((this is LiteralCommandNode) == (other is LiteralCommandNode)) {
      return sortedKey.compareTo(other.sortedKey);
    }

    return (other is LiteralCommandNode) ? 1 : -1;
  }

  bool get isFork => _forks;

  Iterable<String> get examples;
}
