import 'package:test/test.dart';

import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'simple_command_syntax_exception_type_test.mocks.dart';

@GenerateMocks([CommandExceptionType])
void main() {
  test('createWithContext', () {
    final type = SimpleCommandExceptionType(LiteralMessage('error'));
    final reader = StringReader('Foo bar');

    reader.cursor = 5;

    final exception = type.createWithContext(reader);

    expect(exception.type, equals(type));
    expect(exception.input, equals('Foo bar'));
    expect(exception.cursor, equals(5));
  });

  group('getContext', () {
    test('getContext_none', () {
      final exception = CommandSyntaxException(
        MockCommandExceptionType(),
        LiteralMessage('error'),
      );

      expect(exception.context, equals(null));
    });

    test('getContext_short', () {
      final exception = CommandSyntaxException(
        MockCommandExceptionType(),
        LiteralMessage('error'),
        'Hello world!',
        5,
      );

      expect(exception.context, equals('Hello<--[HERE]'));
    });

    test('getContext_long', () {
      final exception = CommandSyntaxException(
        MockCommandExceptionType(),
        LiteralMessage('error'),
        'Hello world! This has an error in it. Oh dear!',
        20,
      );
      
      expect(exception.context, equals('...d! This ha<--[HERE]'));
    });
  });
}
