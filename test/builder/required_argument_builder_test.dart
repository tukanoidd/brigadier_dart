import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  ArgumentType<int> type = IntegerArgumentType();
  var command = (context) => 1;

  RequiredArgumentBuilder<dynamic, int>? builder;

  setUp(() {
    builder = RequiredArgumentBuilder('foo', type);
  });

  group('testBuild', () {
    test('testBuild', () {
      final node = builder!.build();

      expect(node.name, equals('foo'));
      expect(node.type, equals(type));
    });

    test('testBuildWithExecutor', () {
      final node = builder!.executes(command).build();

      expect(node.name, equals('foo'));
      expect(node.type, equals(type));
      expect(node.command, equals(command));
    });

    test('testBuildWithChildren', () {
      builder!.thenBuilder(
        RequiredArgumentBuilder('bar', IntegerArgumentType()),
      );
      builder!.thenBuilder(
        RequiredArgumentBuilder('baz', IntegerArgumentType()),
      );
      
      final node = builder!.build();
      
      expect(node.children.length, equals(2));
    });
  });
}
