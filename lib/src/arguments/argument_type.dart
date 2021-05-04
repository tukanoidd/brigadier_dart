import 'package:brigadier_dart/src/string_reader.dart';
import 'package:brigadier_dart/src/suggestion/all.dart';
import 'package:brigadier_dart/src/tree/command_node.dart';

abstract class ArgumentType<T> {
  T parse(StringReader reader);

  Future<Suggestions> listSuggestions<K>(
    final CommandNode<K> context,
    final SuggestionsBuilder builder,
  ) => Suggestions.empty;

  Iterable<String> get examples => [];
}
