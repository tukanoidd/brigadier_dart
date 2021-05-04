import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/message.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

class Suggestion implements Comparable<Suggestion> {
  final StringRange _range;
  final String _text;
  final Message? _tooltip;

  Suggestion(
    final StringRange range,
    final String text, [
    final Message? tooltip,
  ])  : _range = range,
        _text = text,
        _tooltip = tooltip;

  StringRange get range => _range;

  String get text => _text;

  Message? get tooltip => _tooltip;

  String apply(final String input) {
    if (_range.start == 0 && _range.end == input.length) return _text;

    final result = StringBuffer();
    if (_range.start > 0) result.write(input.substring(0, _range.start));

    result.write(_text);

    if (range.end < input.length) result.write(input.substring(_range.end));

    return result.toString();
  }

  @override
  bool operator ==(Object other) {
    if (this == other) return true;

    if (!(other is Suggestion)) return false;

    return _range == other._range &&
        _text == other._text &&
        _tooltip == other._tooltip;
  }

  @override
  int get hashCode => hash3(_range, _text, _tooltip);

  @override
  String toString() =>
      'Suggestion{range=$_range, text=\'$_text\', tooltip=\'$_tooltip\'}';

  @override
  int compareTo(Suggestion other) => _text.compareTo(other._text);

  int compareToIgnoreCase(final Suggestion b) =>
      compareIgnoreCase(_text, b.text);

  Suggestion expand(final String command, final StringRange range) {
    if (_range == range) return this;

    final result = StringBuffer();
    if (range.start < _range.start) {
      result.write(command.substring(range.start, _range.start));
    }

    result.write(_text);

    if (range.end > _range.end) {
      result.write(command.substring(_range.end, range.end));
    }

    return Suggestion(range, result.toString(), tooltip);
  }
}
