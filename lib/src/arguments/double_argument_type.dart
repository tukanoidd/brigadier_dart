import 'package:brigadier_dart/src/context/command_context.dart';
import 'package:brigadier_dart/src/exceptions/exceptions.dart';
import 'package:brigadier_dart/src/string_reader.dart';

import 'argument_type.dart';

class DoubleArgumentType extends ArgumentType<double> {
  static final Iterable<String> _EXAMPLES = [
    '0',
    '1.2',
    '0.5',
    '-1',
    '-0.5',
    '-1234.56',
  ];

  final double _minimum;
  final double _maximum;

  DoubleArgumentType([final double? min, final double? max])
      : _minimum = min ?? -double.maxFinite,
        _maximum = max ?? double.maxFinite;

  static double getDouble(
    final CommandContext<dynamic> context,
    final String name,
  ) =>
      context.getArgument<double>(name);

  double get minimum => _minimum;

  double get maximum => _maximum;

  @override
  double parse(final StringReader reader) {
    final start = reader.cursor;
    final result = reader.readDouble();

    if (result < _minimum) {
      reader.cursor = start;
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS.doubleTooLow
          .createWithContext(reader, result, _minimum);
    } else if (result > _maximum) {
      reader.cursor = start;
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS.doubleTooHigh
          .createWithContext(reader, result, _maximum);
    }

    return result;
  }

  @override
  bool operator ==(Object other) {
    if (super == other) return true;
    if (!(other is DoubleArgumentType)) return false;

    return _maximum == other._maximum && _minimum == other._minimum;
  }

  @override
  int get hashCode => (31 * _minimum + _maximum).toInt();

  @override
  String toString() {
    if (_minimum == -double.maxFinite && _maximum == double.maxFinite) {
      return 'double()';
    } else if (_maximum == double.maxFinite) {
      return 'double($_minimum)';
    }

    return 'double($_minimum, $_maximum)';
  }

  @override
  Iterable<String> get examples => _EXAMPLES;
}
