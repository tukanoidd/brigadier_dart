import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'abstract_command_node_test.dart';

class ArgumentCommandNodeTest extends AbstractCommandNodeTest {
  late ArgumentCommandNode<dynamic, int> _node;
  late CommandContextBuilder _contextBuilder;

  @override
  CommandNode get commandNode => _node;

  @override
  void testCommandNode() {
    setUp(() {
      _node = RequiredArgumentBuilder('foo', IntegerArgumentType()).build();
      _contextBuilder = CommandContextBuilder(
        CommandDispatcher(),
        Object(),
        RootCommandNode(),
        0,
      );
    });

    super.testCommandNode();

    test('testParse', () {
      final reader = StringReader('123 456');
      _node.parse(reader, _contextBuilder);

      expect(_contextBuilder.arguments.containsKey('foo'), equals(true));
      expect(_contextBuilder.arguments['foo']!.result, equals(123));
    });

    test('testUsage', () {
      expect(_node.usageText, equals('<foo>'));
    });

    test('testSuggestions', () async {
      final result = await _node.listSuggestions(
          _contextBuilder.build(''), SuggestionsBuilder('', 0));
      expect(result.isEmpty, equals(true));
    });

    test('testEquals', () {
      final command = (context) => 0;

      expect(
        RequiredArgumentBuilder('foo', IntegerArgumentType()).build(),
        equals(RequiredArgumentBuilder('foo', IntegerArgumentType()).build()),
      );
      expect(
        RequiredArgumentBuilder('foo', IntegerArgumentType())
            .executes(command)
            .build(),
        equals(
          RequiredArgumentBuilder('foo', IntegerArgumentType())
              .executes(command)
              .build(),
        ),
      );
      expect(
        RequiredArgumentBuilder('bar', IntegerArgumentType(-100, 100)).build(),
        equals(
          RequiredArgumentBuilder('bar', IntegerArgumentType(-100, 100))
              .build(),
        ),
      );
      expect(
        RequiredArgumentBuilder('foo', IntegerArgumentType(-100, 100)).build(),
        equals(
          RequiredArgumentBuilder('foo', IntegerArgumentType(-100, 100))
              .build(),
        ),
      );
      expect(
        RequiredArgumentBuilder('foo', IntegerArgumentType())
            .thenBuilder(RequiredArgumentBuilder('bar', IntegerArgumentType()))
            .build(),
        equals(
          RequiredArgumentBuilder('foo', IntegerArgumentType())
              .thenBuilder(
                  RequiredArgumentBuilder('bar', IntegerArgumentType()))
              .build(),
        ),
      );
    });

    test('testCreateBuilder', () {
      final builder = _node.createBuilder();

      expect(builder.name, equals(_node.name));
      expect(builder.type, equals(_node.type));
      expect(builder.requirement, equals(_node.requirement));
      expect(builder.command, equals(_node.command));
    });
  }
}

void main() => ArgumentCommandNodeTest().testCommandNode();
