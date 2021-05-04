import 'package:brigadier_dart/src/message.dart';
import 'package:brigadier_dart/src/immutable_string_reader.dart';

import 'command_exception_type.dart';
import 'command_syntax_exception.dart';

typedef DynamicNCommandExceptionTypeFunction = Message Function();

class DynamicNCommandExceptionType implements CommandExceptionType {
  final DynamicNCommandExceptionTypeFunction _function;

  DynamicNCommandExceptionType(
      final DynamicNCommandExceptionTypeFunction function)
      : _function = function;

  CommandSyntaxException create(final List<dynamic>? positionalArgs,
          [Map<Symbol, dynamic>? namedArgs]) =>
      CommandSyntaxException(
          this, Function.apply(_function, positionalArgs, namedArgs));

  CommandSyntaxException createWithContext(final ImmutableStringReader reader,
          final List<dynamic>? positionalArgs,
          [Map<Symbol, dynamic>? namedArgs]) =>
      CommandSyntaxException(
        this,
        Function.apply(_function, positionalArgs, namedArgs),
        reader.string,
        reader.cursor,
      );
}
