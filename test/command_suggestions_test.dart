import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  late CommandDispatcher<dynamic> subject;
  dynamic source;

  setUp(() => subject = CommandDispatcher());

  void testSuggestions(
      final String contents, final int cursor, final StringRange range,
      [final List<String> suggestions = const []]) async {
    final result = await subject
        .getCompletionSuggestions(subject.parseString(contents, source));
    expect(result.range, equals(range));

    final expected =
        suggestions.map((suggestion) => Suggestion(range, suggestion)).toList();
    expect(result.list, equals(expected));
  }

  StringReader inputWithOffset(final String input, final int offset) {
    final result = StringReader(input);
    result.cursor = offset;

    return result;
  }

  group('getCompletionSuggestions_rootCommands', () {
    test('getCompletionSuggestions_rootCommands', () async {
      subject.register(LiteralArgumentBuilder.literal('foo'));
      subject.register(LiteralArgumentBuilder.literal('bar'));
      subject.register(LiteralArgumentBuilder.literal('baz'));

      final result = await subject.getCompletionSuggestions(
        subject.parseString('', source),
      );

      expect(result.range, equals(StringRange.at(0)));
      expect(
        result.list,
        equals([
          Suggestion(StringRange.at(0), 'bar'),
          Suggestion(StringRange.at(0), 'baz'),
          Suggestion(StringRange.at(0), 'foo'),
        ]),
      );
    });

    test('getCompletionSuggestions_rootCommands_withInputOffset', () async {
      subject.register(LiteralArgumentBuilder.literal('foo'));
      subject.register(LiteralArgumentBuilder.literal('bar'));
      subject.register(LiteralArgumentBuilder.literal('baz'));

      final result = await subject.getCompletionSuggestions(
        subject.parseReader(inputWithOffset('OOO', 3), source),
      );

      expect(result.range, equals(StringRange.at(3)));
      expect(
        result.list,
        equals([
          Suggestion(StringRange.at(3), 'bar'),
          Suggestion(StringRange.at(3), 'baz'),
          Suggestion(StringRange.at(3), 'foo'),
        ]),
      );
    });

    test('getCompletionSuggestions_rootCommands_partial', () async {
      subject.register(LiteralArgumentBuilder.literal('foo'));
      subject.register(LiteralArgumentBuilder.literal('bar'));
      subject.register(LiteralArgumentBuilder.literal('baz'));

      final result = await subject.getCompletionSuggestions(
        subject.parseString('b', source),
      );

      expect(result.range, equals(StringRange.between(0, 1)));
      expect(
        result.list,
        equals([
          Suggestion(StringRange.between(0, 1), 'bar'),
          Suggestion(StringRange.between(0, 1), 'baz'),
        ]),
      );
    });

    test(
      'getCompletionSuggestions_rootCommands_partial_withInputOffset',
      () async {
        subject.register(LiteralArgumentBuilder.literal('foo'));
        subject.register(LiteralArgumentBuilder.literal('bar'));
        subject.register(LiteralArgumentBuilder.literal('baz'));

        final result = await subject.getCompletionSuggestions(
          subject.parseReader(inputWithOffset('Zb', 1), source),
        );

        expect(result.range, equals(StringRange.between(1, 2)));
        expect(
          result.list,
          equals([
            Suggestion(StringRange.between(1, 2), 'bar'),
            Suggestion(StringRange.between(1, 2), 'baz'),
          ]),
        );
      },
    );
  });

  group('getCompletionSuggestions_subCommands', () {
    test('getCompletionSuggestions_subCommands', () async {
      subject.register(
        LiteralArgumentBuilder.literal('parent')
            .thenBuilder(LiteralArgumentBuilder.literal('foo'))
            .thenBuilder(LiteralArgumentBuilder.literal('bar'))
            .thenBuilder(LiteralArgumentBuilder.literal('baz')),
      );

      final result = await subject.getCompletionSuggestions(
        subject.parseString(
          'parent ',
          source,
        ),
      );

      expect(result.range, equals(StringRange.at(7)));
      expect(
        result.list,
        equals([
          Suggestion(StringRange.at(7), 'bar'),
          Suggestion(StringRange.at(7), 'baz'),
          Suggestion(StringRange.at(7), 'foo'),
        ]),
      );
    });

    test('getCompletionSuggestions_movingCursor_subCommands', () {
      subject.register(LiteralArgumentBuilder.literal('parent_one')
          .thenBuilder(LiteralArgumentBuilder.literal('faz'))
          .thenBuilder(LiteralArgumentBuilder.literal('fbz'))
          .thenBuilder(LiteralArgumentBuilder.literal('gaz')));

      subject.register(LiteralArgumentBuilder.literal('parent_two'));

      testSuggestions(
        'parent_one faz ',
        0,
        StringRange.at(0),
        ['parent_one', 'parent_two'],
      );
      testSuggestions(
        'parent_one faz ',
        1,
        StringRange.between(0, 1),
        ['parent_one', 'parent_two'],
      );
      testSuggestions(
        'parent_one faz ',
        7,
        StringRange.between(0, 7),
        ['parent_one', 'parent_two'],
      );
      testSuggestions(
        'parent_one faz ',
        8,
        StringRange.between(0, 8),
        ['parent_one'],
      );
      testSuggestions('parent_one faz ', 10, StringRange.at(0));
      testSuggestions(
        'parent_one faz ',
        11,
        StringRange.at(11),
        ['faz', 'fbz', 'gaz'],
      );
      testSuggestions(
        'parent_one faz ',
        12,
        StringRange.between(11, 12),
        ['faz', 'fbz'],
      );
      testSuggestions(
        'parent_one faz ',
        13,
        StringRange.between(11, 13),
        ['faz'],
      );
      testSuggestions('parent_one faz ', 14, StringRange.at(0));
      testSuggestions('parent_one faz ', 15, StringRange.at(0));
    });

    test('getCompletionSuggestions_subCommands_partial', () async {
      subject.register(LiteralArgumentBuilder.literal('parent')
          .thenBuilder(LiteralArgumentBuilder.literal('foo'))
          .thenBuilder(LiteralArgumentBuilder.literal('bar'))
          .thenBuilder(LiteralArgumentBuilder.literal('baz')));

      final parse = subject.parseString('parent b', source);
      final result = await subject.getCompletionSuggestions(parse);

      expect(result.range, equals(StringRange.between(7, 8)));
      expect(
        result.list,
        equals([
          Suggestion(StringRange.between(7, 8), 'bar'),
          Suggestion(StringRange.between(7, 8), 'baz'),
        ]),
      );
    });

    test(
      'getCompletionSuggestions_subCommands_partial_withInputOffset',
      () async {
        subject.register(LiteralArgumentBuilder.literal('parent')
            .thenBuilder(LiteralArgumentBuilder.literal('foo'))
            .thenBuilder(LiteralArgumentBuilder.literal('bar'))
            .thenBuilder(LiteralArgumentBuilder.literal('baz')));

        final parse = subject.parseReader(
          inputWithOffset('junk parent b', 5),
          source,
        );
        final result = await subject.getCompletionSuggestions(parse);

        expect(result.range, equals(StringRange.between(12, 13)));
        expect(
          result.list,
          equals([
            Suggestion(StringRange.between(12, 13), 'bar'),
            Suggestion(StringRange.between(12, 13), 'baz')
          ]),
        );
      },
    );
  });

  group('getCompletionSuggestions_redirect', () {
    test('getCompletionSuggestions_redirect', () async {
      final actual = subject.register(
        LiteralArgumentBuilder.literal('actual')
            .thenBuilder(LiteralArgumentBuilder.literal('sub')),
      );
      subject.register(
        LiteralArgumentBuilder.literal('redirect').redirect(actual),
      );

      final parse = subject.parseString('redirect ', source);
      final result = await subject.getCompletionSuggestions(parse);

      expect(result.range, equals(StringRange.at(9)));
      expect(result.list, equals([Suggestion(StringRange.at(9), 'sub')]));
    });

    test('getCompletionSuggestions_redirectPartial', () async {
      final actual = subject.register(
        LiteralArgumentBuilder.literal('actual')
            .thenBuilder(LiteralArgumentBuilder.literal('sub')),
      );
      subject.register(
        LiteralArgumentBuilder.literal('redirect').redirect(actual),
      );

      final parse = subject.parseString('redirect s', source);
      final result = await subject.getCompletionSuggestions(parse);

      expect(result.range, equals(StringRange.between(9, 10)));
      expect(
        result.list,
        equals([Suggestion(StringRange.between(9, 10), 'sub')]),
      );
    });

    test('getCompletionSuggestions_movingCursor_redirect', () {
      final actualOne = subject.register(
        LiteralArgumentBuilder.literal('actual_one')
            .thenBuilder(LiteralArgumentBuilder.literal('faz'))
            .thenBuilder(LiteralArgumentBuilder.literal('fbz'))
            .thenBuilder(LiteralArgumentBuilder.literal('gaz')),
      );

      final actualTwo = subject.register(
        LiteralArgumentBuilder.literal('actual_two'),
      );

      subject.register(
        LiteralArgumentBuilder.literal('redirect_one').redirect(actualOne),
      );
      subject.register(
        LiteralArgumentBuilder.literal('redirect_two').redirect(actualTwo),
      );

      testSuggestions(
        'redirect_one faz ',
        0,
        StringRange.at(0),
        ['actual_one', 'actual_two', 'redirect_one', 'redirect_two'],
      );
      testSuggestions(
        'redirect_one faz ',
        9,
        StringRange.between(0, 9),
        ['redirect_one', 'redirect_two'],
      );
      testSuggestions(
        'redirect_one faz ',
        10,
        StringRange.between(0, 10),
        ['redirect_one'],
      );
      testSuggestions('redirect_one faz ', 12, StringRange.at(0));
      testSuggestions(
        'redirect_one faz ',
        13,
        StringRange.at(13),
        ['faz', 'fbz', 'gaz'],
      );
      testSuggestions(
        'redirect_one faz ',
        14,
        StringRange.between(13, 14),
        ['faz', 'fbz'],
      );
      testSuggestions(
        'redirect_one faz ',
        15,
        StringRange.between(13, 15),
        ['faz'],
      );
      testSuggestions('redirect_one faz ', 16, StringRange.at(0));
      testSuggestions('redirect_one faz ', 17, StringRange.at(0));
    });

    test('getCompletionSuggestions_redirectPartial_withInputOffset', () async {
      final actual = subject.register(
        LiteralArgumentBuilder.literal('actual').thenBuilder(
          LiteralArgumentBuilder.literal('sub'),
        ),
      );
      subject.register(
        LiteralArgumentBuilder.literal('redirect').redirect(actual),
      );

      final parse = subject.parseReader(
        inputWithOffset('/redirect s', 1),
        source,
      );
      final result = await subject.getCompletionSuggestions(parse);

      expect(result.range, equals(StringRange.between(10, 11)));
      expect(
        result.list,
        equals([Suggestion(StringRange.between(10, 11), 'sub')]),
      );
    });

    test('getCompletionSuggestions_redirect_lots', () async {
      final loop = subject.register(LiteralArgumentBuilder.literal('redirect'));

      subject.register(
        LiteralArgumentBuilder.literal('redirect').thenBuilder(
          LiteralArgumentBuilder.literal('loop').thenBuilder(
            RequiredArgumentBuilder.argument(
              'loop',
              IntegerArgumentType.integer(),
            ).redirect(loop),
          ),
        ),
      );

      final result = await subject.getCompletionSuggestions(
        subject.parseString('redirect loop 1 loop 02 loop 003 ', source),
      );

      expect(result.range, equals(StringRange.at(33)));
      expect(result.list, equals([Suggestion(StringRange.at(33), 'loop')]));
    });
  });

  group('getCompletionSuggestions_execute', () {
    test('getCompletionSuggestions_execute_simulation', () async {
      final execute = subject.register(
        LiteralArgumentBuilder.literal('execute'),
      );
      subject.register(
        LiteralArgumentBuilder.literal('execute')
            .thenBuilder(
              LiteralArgumentBuilder.literal('as').thenBuilder(
                RequiredArgumentBuilder.argument(
                  'name',
                  StringArgumentType.word(),
                ).redirect(execute),
              ),
            )
            .thenBuilder(
              LiteralArgumentBuilder.literal('store').thenBuilder(
                RequiredArgumentBuilder.argument(
                  'name',
                  StringArgumentType.word(),
                ).redirect(execute),
              ),
            )
            .thenBuilder(
              LiteralArgumentBuilder.literal('run').executes((c) => 0),
            ),
      );

      final parse = subject.parseString('execute as Dinnerbone as', source);
      final result = await subject.getCompletionSuggestions(parse);

      expect(result.isEmpty, equals(true));
    });

    test('getCompletionSuggestions_execute_simulation_partial', () async {
      final execute = subject.register(
        LiteralArgumentBuilder.literal('execute'),
      );
      subject.register(
        LiteralArgumentBuilder.literal('execute')
            .thenBuilder(
              LiteralArgumentBuilder.literal('as')
                  .thenBuilder(
                    LiteralArgumentBuilder.literal('bar').redirect(execute),
                  )
                  .thenBuilder(
                    LiteralArgumentBuilder.literal('baz').redirect(execute),
                  ),
            )
            .thenBuilder(
              LiteralArgumentBuilder.literal('store').thenBuilder(
                RequiredArgumentBuilder.argument(
                  'name',
                  StringArgumentType.word(),
                ).redirect(execute),
              ),
            )
            .thenBuilder(
              LiteralArgumentBuilder.literal('run').executes((c) => 0),
            ),
      );

      final parse = subject.parseString('execute as bar as ', source);
      final result = await subject.getCompletionSuggestions(parse);

      expect(result.range, equals(StringRange.at(18)));
      expect(
        result.list,
        equals([
          Suggestion(StringRange.at(18), 'bar'),
          Suggestion(StringRange.at(18), 'baz')
        ]),
      );
    });
  });
}
