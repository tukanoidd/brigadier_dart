import 'dart:collection';

import 'package:brigadier_dart/src/command.dart';
import 'package:brigadier_dart/src/redirect_modifier.dart';
import 'package:brigadier_dart/src/tree/tree.dart';

import 'context.dart';
import 'parsed_command_node.dart';

class CommandContext<T> {
  final T _source;
  final String _input;
  final Command<T>? _command;
  final Map<String, ParsedArgument<T, dynamic>> _arguments;
  final CommandNode<T> _rootNode;
  final List<ParsedCommandNode<T>> _nodes;
  final StringRange _range;
  final CommandContext<T>? _child;
  final RedirectModifier<T>? _modifier;
  final bool _forks;

  CommandContext(
    final T source,
    final String input,
    final Map<String, ParsedArgument<T, dynamic>> arguments,
    final Command<T>? command,
    final CommandNode<T> rootNode,
    final List<ParsedCommandNode<T>> nodes,
    final StringRange range,
    final CommandContext<T>? child,
    final RedirectModifier<T>? modifier,
    bool forks,
  )   : _source = source,
        _input = input,
        _arguments = arguments,
        _command = command,
        _rootNode = rootNode,
        _nodes = nodes,
        _range = range,
        _child = child,
        _modifier = modifier,
        _forks = forks;

  CommandContext<T> copyFor(final T source) {
    if (_source == _source) return this;

    return CommandContext<T>(
      source,
      _input,
      _arguments,
      _command,
      _rootNode,
      _nodes,
      _range,
      _child,
      _modifier,
      _forks,
    );
  }

  CommandContext<T>? get child => _child;

  CommandContext<T> get lastChild {
    var result = this;
    while (result.child != null) {
      result = result.child!;
    }

    return result;
  }

  Command<T>? get command => _command;

  T get source => _source;

  V getArgument<V>(final String name) {
    final argument = _arguments[name];

    if (argument == null) {
      throw ArgumentError('No such argument \'$name\' exists on this command');
    }

    final V? result = argument.result as V;

    if (result != null) {
      return result;
    } else {
      throw ArgumentError(
          'Argument \'$name\' is defined as ${result.runtimeType}, not ${V.toString()}');
    }
  }

  @override
  bool operator ==(Object other) {
    if (this == other) return true;
    if (!(other is CommandContext)) return false;

    if (_arguments != other._arguments) return false;
    if (_rootNode != other._rootNode) return false;
    if (_nodes.length != other._nodes.length || _nodes != other._nodes) {
      return false;
    }
    if (_command != null
        ? (_command != other._command)
        : (other._command != null)) return false;
    if (_source != other._source) return false;
    if (_child != null ? (_child != other.child) : (other._child != null)) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode {
    var result = _source.hashCode;

    result = 31 * result + _arguments.hashCode;
    result = 31 * result + (_command != null ? _command.hashCode : 0);
    result = 31 * result + _rootNode.hashCode;
    result = 31 * result + _nodes.hashCode;
    result = 31 * result + (_child != null ? _child.hashCode : 0);

    return result;
  }

  RedirectModifier<T>? get redirectModifier => _modifier;

  StringRange get range => _range;

  String get input => _input;

  CommandNode<T> get rootNode => _rootNode;

  List<ParsedCommandNode<T>> get nodes => _nodes;

  bool get hasNodes => _nodes.isNotEmpty;

  bool get isForked => _forks;
}
