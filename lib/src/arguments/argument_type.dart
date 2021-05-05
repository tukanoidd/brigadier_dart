import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/string_reader.dart';
import 'package:brigadier_dart/src/suggestion/all.dart';

abstract class ArgumentType<T> {
  T parse(StringReader reader);

  Future<Suggestions> listSuggestions<K>(
    final CommandContext<K> context,
    final SuggestionsBuilder builder,
  ) => Suggestions.empty;

  Iterable<String> get examples => [];
}
