import 'package:brigadier_dart/src/context/context.dart';

import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/suggestion/suggestion.dart';
import 'package:quiver/core.dart';

class IntegerSuggestion extends Suggestion {
  int _value;

  IntegerSuggestion(final StringRange range, final int value,
      [final Message? tooltip])
      : _value = value,
        super(range, value.toString(), tooltip);

  int get value => _value;

  @override
  bool operator ==(Object other) {
    if (super == other) return true;

    if (!(other is IntegerSuggestion)) return false;

    return _value == other._value && super == other;
  }

  @override
  int get hashCode => hash2(super.hashCode, _value);

  @override
  String toString() =>
      'IntegerSuggestion{value=$_value, range=$range}, text=\'$text\', tooltip=\'$tooltip}\'';

  @override
  int compareTo(Suggestion other) {
    if (other is IntegerSuggestion) return _value.compareTo(other._value);

    return super.compareTo(other);
  }

  @override
  int compareToIgnoreCase(Suggestion b) => compareTo(b);
}
