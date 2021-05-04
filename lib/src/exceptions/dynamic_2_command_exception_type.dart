import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/immutable_string_reader.dart';

import 'command_exception_type.dart';
import 'command_syntax_exception.dart';

typedef Dynamic2CommandExceptionTypeFunction = Message Function(dynamic, dynamic);

class Dynamic2CommandExceptionType implements CommandExceptionType {
  final Dynamic2CommandExceptionTypeFunction _function;

  Dynamic2CommandExceptionType(
      final Dynamic2CommandExceptionTypeFunction function)
      : _function = function;

  CommandSyntaxException create(final dynamic a, final dynamic b) =>
      CommandSyntaxException(this, _function(a, b));

  CommandSyntaxException createWithContext(
    final ImmutableStringReader reader,
    final dynamic a,
    final dynamic b,
  ) =>
      CommandSyntaxException(
        this,
        _function(a, b),
        reader.string,
        reader.cursor,
      );
}
