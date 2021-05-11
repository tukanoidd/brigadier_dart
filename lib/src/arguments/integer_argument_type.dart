import 'package:brigadier_dart/src/context/command_context.dart';
import 'package:brigadier_dart/src/exceptions/exceptions.dart';
import 'package:brigadier_dart/src/string_reader.dart';

import 'argument_type.dart';

import 'package:brigadier_dart/src/helpers.dart';

class IntegerArgumentType extends ArgumentType<int> {
  static final Iterable<String> _EXAMPLES = ['0', '123', '-123'];

  final int _minimum;
  final int _maximum;

  IntegerArgumentType([final int? min, final int? max])
      : _minimum = min ?? IntHelper.intMinFinite,
        _maximum = max ?? IntHelper.intMaxFinite;

  static int getInteger(
    final CommandContext<dynamic> context,
    final String name,
  ) =>
      context.getArgument<int>(name);

  int get minimum => _minimum;

  int get maximum => _maximum;

  @override
  int parse(final StringReader reader) {
    final start = reader.cursor;
    final result = reader.readInt();

    if (result < _minimum) {
      reader.cursor = start;
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS.integerTooLow
          .createWithContext(reader, result, _minimum);
    }

    if (result > _maximum) {
      reader.cursor = start;
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS.integerTooHigh
          .createWithContext(reader, result, _maximum);
    }

    return result;
  }

  @override
  bool operator ==(Object other) {
    if (super == other) return true;
    if (!(other is IntegerArgumentType)) return false;

    return _maximum == other._maximum && _minimum == other._minimum;
  }

  @override
  int get hashCode => 31 * _minimum + _maximum;

  @override
  String toString() {
    if (_minimum == IntHelper.intMinFinite &&
        _maximum == IntHelper.intMaxFinite) {
      return 'integer()';
    } else if (_maximum == IntHelper.intMaxFinite) {
      return 'integer($_minimum)';
    }

    return 'integer($_minimum, $_maximum)';
  }

  @override
  Iterable<String> get examples => _EXAMPLES;
}
