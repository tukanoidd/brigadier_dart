import 'package:brigadier_dart/src/arguments/argument_type.dart';
import 'package:brigadier_dart/src/suggestion/all.dart';

import 'command_node.dart';

class ArgumentCommandNode<T, K> extends CommandNode<T> {
  static final String USAGE_ARGUMENT_OPEN = '<';
  static final String USAGE_ARGUMENT_CLOSE = '>';

  final String _name;
  final ArgumentType<T> _type;
  final SuggestionProvider<T> _customSuggestions;
}