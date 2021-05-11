import 'package:brigadier_dart/src/command.dart';
import 'package:brigadier_dart/src/command_dispatcher.dart';
import 'package:brigadier_dart/src/context/command_context.dart';
import 'package:brigadier_dart/src/redirect_modifier.dart';
import 'package:brigadier_dart/src/tree/tree.dart';
import 'package:quiver/collection.dart';

import 'parsed_command_node.dart';

import 'parsed_argument.dart';
import 'string_range.dart';
import 'suggestion_context.dart';

class CommandContextBuilder<T> {
  final Map<String, ParsedArgument<T, dynamic>> _arguments = {};
  final CommandNode<T> _rootNode;
  final List<ParsedCommandNode<T>> _nodes = [];
  final CommandDispatcher<T> _dispatcher;
  T _source;
  Command<T>? _command;
  CommandContextBuilder<T>? _child;
  StringRange _range;
  RedirectModifier<T>? _modifier;
  bool _forks;

  CommandContextBuilder(final CommandDispatcher<T> dispatcher, final T source,
      final CommandNode<T> rootNode, final int start)
      : _rootNode = rootNode,
        _dispatcher = dispatcher,
        _source = source,
        _range = StringRange.at(start),
        _forks = false;

  CommandContextBuilder<T> withSource(final T source) {
    _source = source;
    return this;
  }

  T get source => _source;

  CommandNode<T> get rootNode => _rootNode;

  CommandContextBuilder<T> withArgument(
      final String name, final ParsedArgument<T, dynamic> argument) {
    _arguments[name] = argument;
    return this;
  }

  Map<String, ParsedArgument<T, dynamic>> get arguments => _arguments;

  CommandContextBuilder<T> withCommand(final Command<T>? command) {
    _command = command;
    return this;
  }

  CommandContextBuilder<T> withNode(
      final CommandNode<T> node, final StringRange range) {
    _nodes.add(ParsedCommandNode(node, range));
    _range = StringRange.encompassing(_range, range);
    _modifier = node.redirectModifier;
    _forks = node.isFork;

    return this;
  }

  CommandContextBuilder<T> copy() {
    final copy = CommandContextBuilder<T>(
      _dispatcher,
      _source,
      _rootNode,
      _range.start,
    );

    copy._command = _command;
    copy._arguments.addAll(_arguments);
    copy._nodes.addAll(_nodes);
    copy._child = _child;
    copy._range = _range;
    copy._forks = _forks;

    return copy;
  }

  CommandContextBuilder<T> withChild(final CommandContextBuilder<T> child) {
    _child = child;
    return this;
  }

  CommandContextBuilder<T>? get child => _child;

  CommandContextBuilder<T>? get lastChild {
    var result = this;

    while (result.child != null) {
      result = result.child!;
    }

    return result;
  }

  Command<T>? get command => _command;

  List<ParsedCommandNode<T>> get nodes => _nodes;

  CommandContext<T> build(final String input) => CommandContext(
        _source,
        input,
        _arguments,
        _command,
        _rootNode,
        _nodes,
        _range,
        _child == null ? null : child!.build(input),
        _modifier,
        _forks,
      );

  CommandDispatcher<T> get dispatcher => _dispatcher;

  StringRange get range => _range;

  SuggestionContext<T> findSuggestionContext(final int cursor) {
    if (_range.start <= cursor) {
      if (_range.end < cursor) {
        if (_child != null) {
          return _child!.findSuggestionContext(cursor);
        } else if (_nodes.isNotEmpty) {
          final last = nodes.last;
          return SuggestionContext<T>(last.node, last.range.end + 1);
        } else {
          return SuggestionContext<T>(_rootNode, _range.start);
        }
      } else {
        CommandNode<T>? prev = _rootNode;
        for (final node in _nodes) {
          final nodeRange = node.range;
          if (nodeRange.start <= cursor && cursor <= nodeRange.end) {
            return SuggestionContext<T>(prev, nodeRange.start);
          }

          prev = node.node;
        }

        if (prev == null) {
          throw Exception('Can\'t find node before cursor');
        }
        return SuggestionContext<T>(prev, range.start);
      }
    }

    throw Exception('Can\'t find node before cursor');
  }
}
