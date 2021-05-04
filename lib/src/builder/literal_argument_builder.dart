import 'package:brigadier_dart/src/tree/command_node.dart';
import 'package:brigadier_dart/src/tree/literal_command_node.dart';
import 'package:meta/meta.dart';

import 'argument_builder.dart';

class LiteralArgumentBuilder<T>
    extends ArgumentBuilder<T, LiteralArgumentBuilder<T>> {
  final String _literal;

  @protected
  LiteralArgumentBuilder(final String literal) : _literal = literal;

  static LiteralArgumentBuilder<T> literal<T>(final String name) =>
      LiteralArgumentBuilder<T>(name);

  @override
  LiteralArgumentBuilder<T> getThis() => this;

  String get literalVar => _literal;

  @override
  LiteralCommandNode<T> build() {
    final result = LiteralCommandNode<T>(_literal, command, requirement, redirected, redirectModifier, isFork);

    for (final argument in arguments) {
      result.addChild(argument);
    }

    return result;
  }
}
