import 'package:quiver/core.dart';

import 'string_range.dart';

class ParsedArgument<T, K> {
  final StringRange _range;
  final K _result;

  ParsedArgument(final int start, final int end, final K result)
      : _range = StringRange.between(start, end),
        _result = result;

  StringRange get range => _range;

  K get result => _result;

  @override
  bool operator ==(Object other) {
    if (this == other) return true;

    if (!(other is ParsedArgument)) return false;

    return _range == other._range && _result == other._result;
  }

  @override
  int get hashCode => hash2(_range, _result);
}
