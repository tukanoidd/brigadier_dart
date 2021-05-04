import 'package:brigadier_dart/src/single_redirect_modifier.dart';
import 'package:brigadier_dart/src/tree/tree.dart';
import 'package:meta/meta.dart';

import 'package:brigadier_dart/src/command.dart';
import 'package:brigadier_dart/src/helpers.dart';
import 'package:brigadier_dart/src/redirect_modifier.dart';
import 'package:brigadier_dart/src/tree/root_command_node.dart';

abstract class ArgumentBuilder<T, K extends ArgumentBuilder<T, K>> {
  final RootCommandNode<T> _arguments = RootCommandNode();
  late Command<T> _command;
  Predicate<T> _requirement = (s) => true;
  CommandNode<T>? _target;
  RedirectModifier<T>? _modifier;
  late bool _forks;

  @protected
  K getThis();

  K thenBuilder(final ArgumentBuilder<T, dynamic> argument) {
    if (_target != null) {
      throw Exception('Cannot add children to a redirected node');
    }

    _arguments.addChild(argument.build());

    return getThis();
  }

  K thenCommand(final CommandNode<T> argument) {
    if (_target != null) {
      throw Exception('Cannot add children to a redirected node');
    }

    _arguments.addChild(argument);

    return getThis();
  }

  Iterable<CommandNode<T>> get arguments => _arguments.children;

  K executes(final Command<T> command) {
    _command = command;

    return getThis();
  }

  Command<T> get command => _command;

  K requires(final Predicate<T> requirement) {
    _requirement = requirement;

    return getThis();
  }

  Predicate<T> get requirement => _requirement;

  K redirect(
    final CommandNode<T> target, [
    final SingleRedirectModifier<T>? modifier,
  ]) =>
      forward(
        target,
        modifier == null ? null : (o) => Set.unmodifiable([modifier.apply(o)]),
        false,
      );

  K fork(final CommandNode<T> target, final RedirectModifier<T> modifier) =>
      forward(target, modifier, true);

  K forward(final CommandNode<T>? target, final RedirectModifier<T>? modifier,
      final bool fork) {
    if (_arguments.children.isEmpty) {
      throw Exception('Cannot forward a node with children');
    }

    _target = target;
    _modifier = modifier;
    _forks = fork;

    return getThis();
  }

  CommandNode<T>? get redirected => _target;

  RedirectModifier<T>? get redirectModifier => _modifier;

  bool get isFork => _forks;

  CommandNode<T> build();
}
