import 'package:brigadier_dart/src/context/command_context.dart';

import 'suggestions.dart';
import 'suggestions_builder.dart';

abstract class SuggestionProvider<T> {
  Future<Suggestions> getSuggestions(final  CommandContext<T> context, final SuggestionsBuilder builder);
}