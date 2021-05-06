import 'dart:collection';
import 'dart:math' as math;

import 'package:quiver/core.dart';

import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/suggestion/suggestion.dart';

import 'package:brigadier_dart/src/helpers.dart';

class Suggestions with IntMixin {
  static final Suggestions _EMPTY = Suggestions(StringRange.at(0), []);

  final StringRange _range;
  final List<Suggestion> _suggestions;

  Suggestions(final StringRange range, final List<Suggestion> suggestions)
      : _range = range,
        _suggestions = suggestions;

  StringRange get range => _range;

  List<Suggestion> get list => _suggestions;

  bool get isEmpty => _suggestions.isEmpty;

  @override
  bool operator ==(Object other) {
    if (super == other) return true;

    if (!(other is Suggestions)) return false;

    return _range == other._range && _suggestions == other._suggestions;
  }

  @override
  int get hashCode => hash2(_range, _suggestions);

  @override
  String toString() => 'Suggestions{range=$_range, suggestions=$_suggestions}';

  static Future<Suggestions> get empty => Future.value(_EMPTY);

  static Suggestions merge(final String command, final Iterable<Suggestions> input) {
    if (input.isEmpty) {
      return _EMPTY;
    } else if (input.length == 1) {
      return HasNextIterator<Suggestions>(input.iterator).next();
    }

    final texts = <Suggestion>{};
    for (final suggestions in input) {
      texts.addAll(suggestions.list);
    }

    return create(command, texts);
  }

  static Suggestions create(final String command, final Iterable<Suggestion> suggestions) {
    if (suggestions.isEmpty) return _EMPTY;

    var start = IntMixin.intMaxFinite;
    var end = IntMixin.intMinFinite;
    for (final suggestion in suggestions) {
      start = math.min(suggestion.range.start, start);
      end = math.max(suggestion.range.end, end);
    }

    final range = StringRange(start, end);
    final texts = <Suggestion>{};
    for (final suggestion in suggestions) {
      texts.add(suggestion.expand(command, range));
    }

    final sorted = texts.toList();
    sorted.sort((a, b) => a.compareToIgnoreCase(b));

    return Suggestions(range, sorted);
  }
}
