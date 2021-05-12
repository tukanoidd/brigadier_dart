import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'abstract_command_node_test.dart';

class RootCommandNodeTest extends AbstractCommandNodeTest {
  late RootCommandNode _node;

  @override
  CommandNode get commandNode => _node;

  @override
  void testCommandNode() {
    setUp(() {
      _node = RootCommandNode();
    });

    super.testCommandNode();

    test('testParse', () {
      final reader = StringReader('hello world');

      _node.parse(
        reader,
        CommandContextBuilder(
          CommandDispatcher(),
          Object(),
          RootCommandNode(),
          0,
        ),
      );

      expect(reader.cursor, equals(0));
    });

    test('testAddChildNoRoot', () {
      expect(() => _node.addChild(RootCommandNode()), throwsException);
    });

    test('testUsage', () {
      expect(_node.usageText, equals(''));
    });

    test('testSuggestions', () async {
      final context = CommandContext(
        Object(),
        '',
        {},
        command,
        RootCommandNode(),
        [],
        StringRange(0, 0),
        null,
        null,
        false,
      );

      final result = await _node.listSuggestions(
        context,
        SuggestionsBuilder('', 0),
      );

      expect(result.isEmpty, equals(true));
    });

    test('testCreateBuilder', () {
      expect(() => _node.createBuilder(), throwsException);
    });

    test('testEquals', () {
      expect(RootCommandNode(), equals(RootCommandNode()));
      expect(
        RootCommandNode()..addChild(LiteralArgumentBuilder('foo').build()),
        equals(
          RootCommandNode()..addChild(LiteralArgumentBuilder('foo').build()),
        ),
      );
    });
  }
}

void main() => RootCommandNodeTest().testCommandNode();
