import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/suggestion/integer_suggestion.dart';
import 'package:brigadier_dart/src/suggestion/suggestions.dart';

import 'suggestion.dart';

class SuggestionsBuilder {
  final String _input;
  late final String _inputLowerCase;
  final int _start;
  final String _remaining;
  late final String _remainingLowerCase;
  final List<Suggestion> _result = [];

  SuggestionsBuilder(final String input, final int start,
      [final String? inputLowerCase])
      : _input = input,
        _start = start,
        _remaining = input.substring(start) {
    final lower = inputLowerCase ?? input.toLowerCase();

    _inputLowerCase = lower;
    _remainingLowerCase = lower.substring(start);
  }

  String get input => _input;

  int get start => _start;

  String get remaining => _remaining;

  String get remainingLowerCase => _remainingLowerCase;

  Suggestions build() => Suggestions.create(_input, _result);

  Future<Suggestions> buildFuture() => Future.value(build());

  SuggestionsBuilder suggest(final dynamic value, [final Message? tooltip]) {
    if (value is String) {
      if (value == _remaining) return this;

      _result.add(
        Suggestion(
          StringRange.between(start, _input.length),
          value,
          tooltip,
        ),
      );
    }
    else if (value is int) {
      _result.add(
        IntegerSuggestion(
          StringRange.between(start, _input.length),
          value,
          tooltip,
        ),
      );
    }

    return this;
  }

  SuggestionsBuilder add(final SuggestionsBuilder other) {
    _result.addAll(other._result);

    return this;
  }

  SuggestionsBuilder createOffset(final int start) => SuggestionsBuilder(input, start, _inputLowerCase);

  SuggestionsBuilder restart() => createOffset(start);
}
