import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/immutable_string_reader.dart';

import 'command_exception_type.dart';
import 'command_syntax_exception.dart';

class SimpleCommandExceptionType implements CommandExceptionType {
  final Message _message;

  SimpleCommandExceptionType(final Message message) : _message = message;

  CommandSyntaxException create() => CommandSyntaxException(this, _message);

  CommandSyntaxException createWithContext(
      final ImmutableStringReader reader) =>
      CommandSyntaxException(
        this,
        _message,
        reader.string,
        reader.cursor,
      );

  @override
  String toString() => _message.string;
}
