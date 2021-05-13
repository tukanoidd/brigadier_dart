import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'abstract_command_node_test.dart';

class LiteralCommandNodeTest extends AbstractCommandNodeTest {
  late LiteralCommandNode _node;
  late CommandContextBuilder _contextBuilder;

  @override
  CommandNode get commandNode => _node;

  @override
  void testCommandNode() {
    setUp(() {
      _node = LiteralArgumentBuilder('foo').build();
      _contextBuilder = CommandContextBuilder(
        CommandDispatcher(),
        Object(),
        RootCommandNode(),
        0,
      );
    });

    super.testCommandNode();

    group('testParse', () {
      test('testParse', () {
        final reader = StringReader('foo bar');

        _node.parse(reader, _contextBuilder);
        expect(reader.remaining, equals(' bar'));
      });

      test('testParseExact', () {
        final reader = StringReader('foo');

        _node.parse(reader, _contextBuilder);
        expect(reader.remaining, equals(''));
      });

      test('testParseSimilar', () {
        final reader = StringReader('foobar');

        expect(
          () => _node.parse(reader, _contextBuilder),
          throwsA((ex) =>
              ex is CommandSyntaxException &&
              ex.type ==
                  CommandSyntaxException.BUILT_IN_EXCEPTIONS.literalIncorrect &&
              ex.cursor == 0),
        );
      });

      test('testParseInvalid', () {
        final reader = StringReader('bar');

        expect(
          () => _node.parse(reader, _contextBuilder),
          throwsA((ex) =>
              ex is CommandSyntaxException &&
              ex.type ==
                  CommandSyntaxException.BUILT_IN_EXCEPTIONS.literalIncorrect &&
              ex.cursor == 0),
        );
      });
    });

    test('testUsage', () {
      expect(_node.usageText, equals('foo'));
    });

    test('testSuggestions', () async {
      final empty = await _node.listSuggestions(
        _contextBuilder.build(''),
        SuggestionsBuilder('', 0),
      );
      expect(empty.list, equals([Suggestion(StringRange.at(0), 'foo')]));

      final foo = await _node.listSuggestions(
        _contextBuilder.build('foo'),
        SuggestionsBuilder('foo', 0),
      );
      expect(foo.isEmpty, equals(true));

      final food = await _node.listSuggestions(
        _contextBuilder.build('food'),
        SuggestionsBuilder('food', 0),
      );
      expect(food.isEmpty, equals(true));

      final b = await _node.listSuggestions(
        _contextBuilder.build('b'),
        SuggestionsBuilder('b', 0),
      );
      expect(b.isEmpty, equals(true));
    });

    test('testEquals', () {
      final command = (context) => 0;

      expect(
        LiteralArgumentBuilder('foo').build(),
        equals(LiteralArgumentBuilder('foo').build()),
      );
      expect(
        LiteralArgumentBuilder('bar').executes(command).build(),
        equals(LiteralArgumentBuilder('bar').executes(command).build()),
      );
      expect(
        LiteralArgumentBuilder('bar').build(),
        equals(LiteralArgumentBuilder('bar').build()),
      );
      expect(
        LiteralArgumentBuilder('foo')
            .thenBuilder(LiteralArgumentBuilder('bar'))
            .build(),
        equals(
          LiteralArgumentBuilder('foo')
              .thenBuilder(LiteralArgumentBuilder('bar'))
              .build(),
        ),
      );
    });

    test('testCreateBuilder', () {
      final builder = _node.createBuilder();

      expect(builder.literalVar, equals(_node.literal));
      expect(builder.requirement, equals(_node.requirement));
      expect(builder.command, equals(_node.command));
    });
  }
}

void main() => LiteralCommandNodeTest().testCommandNode();
