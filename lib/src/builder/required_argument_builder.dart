import 'package:brigadier_dart/src/tree/argument_command_node.dart';
import 'package:meta/meta.dart';

import 'package:brigadier_dart/src/arguments/argument_type.dart';
import 'package:brigadier_dart/src/suggestion/all.dart';

import 'argument_builder.dart';

class RequiredArgumentBuilder<T, K>
    extends ArgumentBuilder<T, RequiredArgumentBuilder<T, K>> {
  final String _name;
  final ArgumentType<K> _type;
  SuggestionProvider<T>? _suggestionProvider;

  RequiredArgumentBuilder(final String name, final ArgumentType<K> type)
      : _name = name,
        _type = type;

  RequiredArgumentBuilder<T, K> suggests(final SuggestionProvider<T>? provider) {
    _suggestionProvider = provider;
    return getThis();
  }

  SuggestionProvider<T>? get suggestionsProvider => _suggestionProvider;

  @override
  @protected
  RequiredArgumentBuilder<T, K> getThis() => this;

  ArgumentType<K> get type => _type;

  String get name => _name;

  @override
  ArgumentCommandNode<T, K> build() {
    final result = ArgumentCommandNode<T, K>(
      _name,
      _type,
      command,
      requirement,
      redirected,
      redirectModifier,
      isFork,
      _suggestionProvider,
    );

    for (final argument in arguments) {
      result.addChild(argument);
    }

    return result;
  }
}
