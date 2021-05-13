import 'package:test/test.dart';

import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'command_suggestions_test.mocks.dart';

@GenerateMocks([Object])
void main() {
  late CommandDispatcher subject;
  final source = MockObject();

  void testSuggestions(
    final String contents,
    final int cursor,
    final StringRange range,
    final List<String> suggestions,
  ) async {
    final result = await subject.getCompletionSuggestions(
      subject.parseString(contents, source),
      cursor,
    );
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

  setUp(() {
    subject = CommandDispatcher();
  });

  group('getCompletionSuggestions', () {
    group('getCompletionSuggestions_rootCommands', () {
      test('getCompletionSuggestions_rootCommands', () async {
        subject.register(LiteralArgumentBuilder('foo'));
        subject.register(LiteralArgumentBuilder('bar'));
        subject.register(LiteralArgumentBuilder('baz'));

        final result = await subject
            .getCompletionSuggestions(subject.parseString('', source));

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
        subject.register(LiteralArgumentBuilder('foo'));
        subject.register(LiteralArgumentBuilder('bar'));
        subject.register(LiteralArgumentBuilder('baz'));

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
        subject.register(LiteralArgumentBuilder('foo'));
        subject.register(LiteralArgumentBuilder('bar'));
        subject.register(LiteralArgumentBuilder('baz'));

        final result = await subject
            .getCompletionSuggestions(subject.parseString('b', source));

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
          subject.register(LiteralArgumentBuilder('foo'));
          subject.register(LiteralArgumentBuilder('bar'));
          subject.register(LiteralArgumentBuilder('baz'));

          final result = await subject.getCompletionSuggestions(
              subject.parseReader(inputWithOffset('Zb', 1), source));

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
          LiteralArgumentBuilder('parent')
              .thenBuilder(LiteralArgumentBuilder('foo'))
              .thenBuilder(LiteralArgumentBuilder('bar'))
              .thenBuilder(LiteralArgumentBuilder('baz')),
        );

        final result = await subject
            .getCompletionSuggestions(subject.parseString('parent ', source));

        expect(result.range, equals(StringRange.at(7)));
        expect(
          result.list,
          equals([
            Suggestion(StringRange.at(7), 'bar'),
            Suggestion(StringRange.at(7), 'baz'),
            Suggestion(StringRange.at(7), 'foo')
          ]),
        );
      });

      test('getCompletionSuggestions_movingCursor_subCommands', () {
        subject.register(
          LiteralArgumentBuilder('parent_one')
              .thenBuilder(LiteralArgumentBuilder('faz'))
              .thenBuilder(LiteralArgumentBuilder('fbz'))
              .thenBuilder(LiteralArgumentBuilder('gaz')),
        );

        subject.register(LiteralArgumentBuilder('parent_two'));

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
        testSuggestions('parent_one faz ', 10, StringRange.at(0), []);
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
        testSuggestions('parent_one faz ', 14, StringRange.at(0), []);
        testSuggestions('parent_one faz ', 15, StringRange.at(0), []);
      });

      test('getCompletionSuggestions_subCommands_partial', () async {
        subject.register(
          LiteralArgumentBuilder('parent')
              .thenBuilder(LiteralArgumentBuilder('foo'))
              .thenBuilder(LiteralArgumentBuilder('bar'))
              .thenBuilder(LiteralArgumentBuilder('baz')),
        );

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
          subject.register(
            LiteralArgumentBuilder('parent')
                .thenBuilder(LiteralArgumentBuilder('foo'))
                .thenBuilder(LiteralArgumentBuilder('bar'))
                .thenBuilder(LiteralArgumentBuilder('baz')),
          );

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
              Suggestion(StringRange.between(12, 13), 'baz'),
            ]),
          );
        },
      );
    });

    group('getCompletionSuggestions_redirect', () {
      test('getCompletionSuggestions_redirect', () async {
        final actual = subject.register(
          LiteralArgumentBuilder('actual')
              .thenBuilder(LiteralArgumentBuilder('sub')),
        );
        subject.register(LiteralArgumentBuilder('redirect').redirect(actual));

        final parse = subject.parseString('redirect ', source);
        final result = await subject.getCompletionSuggestions(parse);

        expect(result.range, equals(StringRange.at(9)));
        expect(result.list, equals([Suggestion(StringRange.at(9), 'sub')]));
      });

      test('getCompletionSuggestions_redirectPartial', () async {
        final actual = subject.register(
          LiteralArgumentBuilder('actual')
              .thenBuilder(LiteralArgumentBuilder('sub')),
        );
        subject.register(LiteralArgumentBuilder('redirect').redirect(actual));

        final parse = subject.parseString('redirect s', source);
        final result = await subject.getCompletionSuggestions(parse);

        expect(result.range, equals(StringRange.between(9, 10)));
        expect(
          result.list,
          equals([Suggestion(StringRange.between(9, 10), 'sub')]),
        );
      });

      test('getCompletionSuggestions_movingCursor_redirect', () async {
        final actualOne = subject.register(
          LiteralArgumentBuilder('actual_one')
              .thenBuilder(LiteralArgumentBuilder('faz'))
              .thenBuilder(LiteralArgumentBuilder('fbz'))
              .thenBuilder(LiteralArgumentBuilder('gaz')),
        );

        final actualTwo = subject.register(
          LiteralArgumentBuilder('actual_two'),
        );

        subject.register(
          LiteralArgumentBuilder('redirect_one').redirect(actualOne),
        );
        subject.register(
          LiteralArgumentBuilder('redirect_two').redirect(actualTwo),
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
        testSuggestions('redirect_one faz ', 12, StringRange.at(0), []);
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
        testSuggestions('redirect_one faz ', 16, StringRange.at(0), []);
        testSuggestions('redirect_one faz ', 17, StringRange.at(0), []);
      });

      test(
        'getCompletionSuggestions_redirectPartial_withInputOffset',
        () async {
          final actual = subject.register(
            LiteralArgumentBuilder('actual')
                .thenBuilder(LiteralArgumentBuilder('sub')),
          );
          subject.register(LiteralArgumentBuilder('redirect').redirect(actual));

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
        },
      );

      test('getCompletionSuggestions_redirect_lots', () async {
        final loop = subject.register(LiteralArgumentBuilder('redirect'));
        subject.register(
          LiteralArgumentBuilder('redirect').thenBuilder(
            LiteralArgumentBuilder('loop').thenBuilder(
              RequiredArgumentBuilder('loop', IntegerArgumentType())
                  .redirect(loop),
            ),
          ),
        );

        final result = await subject.getCompletionSuggestions(
          subject.parseString('redirect loop 1 loop 02 loop 003 ', source),
        );

        expect(result.range, equals(StringRange.at(33)));
        expect(
          result.list,
          equals([Suggestion(StringRange.at(33), 'loop')]),
        );
      });
    });

    group('getCompletionSuggestions_execute_simulation', () {
      test('getCompletionSuggestions_execute_simulation', () async {
        final execute = subject.register(LiteralArgumentBuilder('execute'));
        subject.register(
          LiteralArgumentBuilder('execute')
              .thenBuilder(
                LiteralArgumentBuilder('as').thenBuilder(
                  RequiredArgumentBuilder('name', StringArgumentType.word())
                      .redirect(execute),
                ),
              )
              .thenBuilder(
                LiteralArgumentBuilder('store').thenBuilder(
                  RequiredArgumentBuilder('name', StringArgumentType.word())
                      .redirect(execute),
                ),
              )
              .thenBuilder(LiteralArgumentBuilder('run').executes((c) => 0)),
        );

        final parse = subject.parseString('execute as Dinnerbone as', source);
        final result = await subject.getCompletionSuggestions(parse);

        expect(result.isEmpty, equals(true));
      });

      test('getCompletionSuggestions_execute_simulation_partial', () async {
        final execute = subject.register(LiteralArgumentBuilder('execute'));
        subject.register(
          LiteralArgumentBuilder('execute')
              .thenBuilder(
                LiteralArgumentBuilder('as')
                    .thenBuilder(
                        LiteralArgumentBuilder('bar').redirect(execute))
                    .thenBuilder(
                        LiteralArgumentBuilder('baz').redirect(execute)),
              )
              .thenBuilder(
                LiteralArgumentBuilder('store').thenBuilder(
                  RequiredArgumentBuilder(
                    'name',
                    StringArgumentType.word(),
                  ).redirect(execute),
                ),
              )
              .thenBuilder(LiteralArgumentBuilder('run').executes((c) => 0)),
        );

        final parse = subject.parseString('execute as bar as ', source);
        final result = await subject.getCompletionSuggestions(parse);

        expect(result.range, equals(StringRange.at(18)));
        expect(
          result.list,
          equals([
            Suggestion(StringRange.at(18), 'bar'),
            Suggestion(StringRange.at(18), 'baz'),
          ]),
        );
      });
    });
  });
}
