import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/immutable_string_reader.dart';

import 'command_exception_type.dart';
import 'command_syntax_exception.dart';

typedef Dynamic4CommandExceptionTypeFunction = Message Function(
    dynamic, dynamic, dynamic, dynamic);

class Dynamic4CommandExceptionType implements CommandExceptionType {
  final Dynamic4CommandExceptionTypeFunction _function;

  Dynamic4CommandExceptionType(
      final Dynamic4CommandExceptionTypeFunction function)
      : _function = function;

  CommandSyntaxException create(
    final dynamic a,
    final dynamic b,
    final dynamic c,
    final dynamic d,
  ) =>
      CommandSyntaxException(this, _function(a, b, c, d));

  CommandSyntaxException createWithContext(
    final ImmutableStringReader reader,
    final dynamic a,
    final dynamic b,
    final dynamic c,
    final dynamic d,
  ) =>
      CommandSyntaxException(
        this,
        _function(a, b, c, d),
        reader.string,
        reader.cursor,
      );
}
