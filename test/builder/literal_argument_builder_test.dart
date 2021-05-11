import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  LiteralArgumentBuilder? builder;
  final command = (context) => 1;

  setUp(() {
    builder = LiteralArgumentBuilder('foo');
  });

  group('testBuild', () {
    test('testBuild', () {
      final node = builder!.build();

      expect(node.literal, equals('foo'));
    });

    test('testBuildWithExecutor', () {
      final node = builder!.executes(command).build();

      expect(node.literal, equals('foo'));
      expect(node.command, equals(command));
    });

    test('testBuildWithChildren', () {
      builder!.thenBuilder(RequiredArgumentBuilder(
        'bar',
        IntegerArgumentType(),
      ));
      builder!.thenBuilder(RequiredArgumentBuilder(
        'baz',
        IntegerArgumentType(),
      ));
      
      final node = builder!.build();
      
      expect(node.children.length, equals(2));
    });
  });
}
