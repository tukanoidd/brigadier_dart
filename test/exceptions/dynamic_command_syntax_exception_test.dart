import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  DynamicCommandExceptionType? type;

  setUp(() {
    type =
        DynamicCommandExceptionType((name) => LiteralMessage('Hello, $name!'));
  });

  test('createWithContext', () {
    final reader = StringReader('Foo bar');
    reader.cursor = 5;

    final exception = type!.createWithContext(reader, 'World');

    expect(exception.type, equals(type));
    expect(exception.input, equals('Foo bar'));
    expect(exception.cursor, equals(5));
  });
}
