import 'dart:math' as math;

import 'package:brigadier_dart/src/message.dart';

import 'built_in_exception_provider.dart';
import 'built_in_exceptions.dart';
import 'command_exception_type.dart';

class CommandSyntaxException implements Exception {
  static const int CONTEXT_AMOUNT = 10;
  static bool ENABLE_COMMAND_STACK_TRACES = true;
  static BuiltInExceptionProvider BUILT_IN_EXCEPTIONS = BuiltInExceptions();

  final CommandExceptionType _type;
  final Message _message;
  final String? _input;
  final int _cursor;

  CommandSyntaxException(
    final CommandExceptionType type,
    final Message message, [
    final String? input,
    final int? cursor,
  ])  : _type = type,
        _message = message,
        _input = input,
        _cursor = cursor ?? -1;

  @override
  String toString() {
    var message = _message.string;
    final ctx = context;

    if (ctx != null) message += ' at position $_cursor: $ctx';

    return message;
  }

  Message get rawMessage => _message;

  String? get context {
    if (_input == null || _cursor < 0) return null;

    final builder = StringBuffer();
    final cursor = math.min(_input!.length, _cursor);

    if (cursor > CONTEXT_AMOUNT) builder.write('...');

    builder
        .write(_input!.substring(math.max(0, cursor - CONTEXT_AMOUNT), cursor));
    builder.write('<--[HERE]');

    return builder.toString();
  }

  CommandExceptionType get type => _type;

  String? get input => _input;

  int get cursor => _cursor;
}
