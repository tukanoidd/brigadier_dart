import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/immutable_string_reader.dart';

import 'command_exception_type.dart';
import 'command_syntax_exception.dart';

typedef Dynamic3CommandExceptionTypeFunction = Message Function(
    dynamic, dynamic, dynamic);

class Dynamic3CommandExceptionType implements CommandExceptionType {
  final Dynamic3CommandExceptionTypeFunction _function;

  Dynamic3CommandExceptionType(
      final Dynamic3CommandExceptionTypeFunction function)
      : _function = function;

  CommandSyntaxException create(
    final dynamic a,
    final dynamic b,
    final dynamic c,
  ) =>
      CommandSyntaxException(this, _function(a, b, c));

  CommandSyntaxException createWithContext(
    final ImmutableStringReader reader,
    final dynamic a,
    final dynamic b,
    final dynamic c,
  ) =>
      CommandSyntaxException(
        this,
        _function(a, b, c),
        reader.string,
        reader.cursor,
      );
}
