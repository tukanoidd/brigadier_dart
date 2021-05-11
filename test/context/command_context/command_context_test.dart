import 'package:test/test.dart';

import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'command_context_test.mocks.dart';

@GenerateMocks([CommandNode, Object, CommandDispatcher])
void main() {
  CommandContextBuilder? builder;

  var source = MockObject();
  var dispatcher = MockCommandDispatcher();
  var rootNode = MockCommandNode();

  setUp(() {
    builder = CommandContextBuilder(dispatcher, source, rootNode, 0);
  });

  group('testGetArgument', () {
    test('testGetArgument_nonexistent', () {
      expect(
        () {
          builder!.build('').getArgument<Object>('foo');
        },
        throwsArgumentError,
      );
    });

    test('testGetArgument_wrongType', () {
      try {
        final context = builder!
            .withArgument('foo', ParsedArgument(0, 1, 123))
            .build('123');
        context.getArgument<String>('foo');

        fail('It shouldn\'t cast');
        // ignore: empty_catches
      } catch (e) {}
    });

    test('testGetArgument', () {
      final context =
          builder!.withArgument('foo', ParsedArgument(0, 1, 123)).build('123');
      expect(context.getArgument<int>('foo'), equals(123));
    });
  });

  test('testSource', () {
    expect(builder!.build('input').source, equals(source));
  });

  test('testRootNode', () {
    expect(builder!.build('').rootNode, equals(rootNode));
  });

  test('testEquals', () {
    final otherSource = Object();
    final command = (context) => 1;
    final otherCommand = (context) => 2;
    final rootNode = MockCommandNode();
    final otherRootNode = MockCommandNode();
    final node = MockCommandNode();
    final otherNode = MockCommandNode();

    expect(
      CommandContextBuilder(dispatcher, source, rootNode, 0).build(''),
      equals(CommandContextBuilder(dispatcher, source, rootNode, 0).build('')),
    );
    expect(
      CommandContextBuilder(dispatcher, source, otherRootNode, 0).build(''),
      equals(
        CommandContextBuilder(dispatcher, source, otherRootNode, 0).build(''),
      ),
    );
    expect(
      CommandContextBuilder(dispatcher, otherSource, rootNode, 0).build(''),
      equals(
        CommandContextBuilder(dispatcher, otherSource, rootNode, 0).build(''),
      ),
    );
    expect(
      CommandContextBuilder(dispatcher, source, rootNode, 0)
          .withCommand(command)
          .build(''),
      equals(
        CommandContextBuilder(dispatcher, source, rootNode, 0)
            .withCommand(command)
            .build(''),
      ),
    );
    expect(
      CommandContextBuilder(dispatcher, source, rootNode, 0)
          .withCommand(otherCommand)
          .build(''),
      equals(
        CommandContextBuilder(dispatcher, source, rootNode, 0)
            .withCommand(otherCommand)
            .build(''),
      ),
    );
    expect(
      CommandContextBuilder(dispatcher, source, rootNode, 0)
          .withArgument('foo', ParsedArgument(0, 1, 123))
          .build('123'),
      equals(
        CommandContextBuilder(dispatcher, source, rootNode, 0)
            .withArgument('foo', ParsedArgument(0, 1, 123))
            .build('123'),
      ),
    );
    expect(
      CommandContextBuilder(dispatcher, source, rootNode, 0)
          .withNode(node, StringRange.between(0, 3))
          .withNode(otherNode, StringRange.between(4, 6))
          .build('123 456'),
      equals(
        CommandContextBuilder(dispatcher, source, rootNode, 0)
            .withNode(node, StringRange.between(0, 3))
            .withNode(otherNode, StringRange.between(4, 6))
            .build('123 456'),
      ),
    );
    expect(
      CommandContextBuilder(dispatcher, source, rootNode, 0)
          .withNode(otherNode, StringRange.between(0, 3))
          .withNode(node, StringRange.between(4, 6))
          .build('123 456'),
      equals(
        CommandContextBuilder(dispatcher, source, rootNode, 0)
            .withNode(otherNode, StringRange.between(0, 3))
            .withNode(node, StringRange.between(4, 6))
            .build('123 456'),
      ),
    );
  });
}
