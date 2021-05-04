import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/immutable_string_reader.dart';

import 'command_exception_type.dart';
import 'command_syntax_exception.dart';

typedef DynamicCommandExceptionTypeFunction = Message Function(dynamic);

class DynamicCommandExceptionType implements CommandExceptionType {
  final DynamicCommandExceptionTypeFunction _function;

  DynamicCommandExceptionType(
      final DynamicCommandExceptionTypeFunction function)
      : _function = function;

  CommandSyntaxException create(final dynamic arg) =>
      CommandSyntaxException(this, _function(arg));

  CommandSyntaxException createWithContext(
    final ImmutableStringReader reader,
    final dynamic arg,
  ) =>
      CommandSyntaxException(
        this,
        _function(arg),
        reader.string,
        reader.cursor,
      );
}
