import 'dart:math' as math;

import 'package:quiver/core.dart';

import 'package:brigadier_dart/src/immutable_string_reader.dart';

class StringRange {
  final int _start;
  final int _end;

  StringRange(final int start, final int end)
      : _start = start,
        _end = end;

  static StringRange at(final int pos) => StringRange(pos, pos);

  static StringRange between(final int start, final int end) =>
      StringRange(start, end);

  static StringRange encompassing(final StringRange a, final StringRange b) =>
      StringRange(math.min(a.start, b.start), math.max(a.end, b.end));

  int get start => _start;

  int get end => _end;

  String getFromReader(final ImmutableStringReader reader) => reader.string.substring(_start, _end);

  String getFromString(final String string) => string.substring(_start, _end);

  bool get isEmpty => _start == _end;

  int get length => _end - _start;

  @override
  bool operator ==(Object other) {
    if (this == other) return true;

    if (!(other is StringRange)) return false;

    return _start == other._start && _end == other._end;
  }

  @override
  int get hashCode => hash2(_start, _end);

  @override
  String toString() => 'StringRange{start=$_start, end=$_end}';
}
