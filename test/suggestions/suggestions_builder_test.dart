import 'dart:math';

import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  late SuggestionsBuilder builder;

  setUp(() {
    builder = SuggestionsBuilder('Hello w', 6);
  });

  group('suggest', () {
    test('suggest_appends', () {
      final result = builder.suggest('world!').build();

      expect(result.list,
          equals([Suggestion(StringRange.between(6, 7), 'world!')]));
      expect(result.range, equals(StringRange.between(6, 7)));
      expect(result.isEmpty, equals(false));
    });

    test('suggest_replaces', () {
      final result = builder.suggest('everybody').build();

      expect(
        result.list,
        equals([Suggestion(StringRange.between(6, 7), 'everybody')]),
      );
      expect(result.range, equals(StringRange.between(6, 7)));
      expect(result.isEmpty, equals(false));
    });

    test('suggest_noop', () {
      final result = builder.suggest('w').build();

      expect(result.list, equals([]));
      expect(result.isEmpty, equals(true));
    });

    test('suggest_multiple', () {
      final result = builder
          .suggest('world!')
          .suggest('everybody')
          .suggest('weekend')
          .build();

      expect(
        result.list,
        equals(
          [
            Suggestion(StringRange.between(6, 7), 'everybody'),
            Suggestion(StringRange.between(6, 7), 'weekend'),
            Suggestion(StringRange.between(6, 7), 'world!'),
          ],
        ),
      );
      expect(result.range, equals(StringRange.between(6, 7)));
      expect(result.isEmpty, equals(false));
    });
  });

  test('restart', () {
    builder.suggest('won\'t be included in restart');

    final other = builder.restart();

    expect(other != builder, equals(true));
    expect(other.input, equals(builder.input));
    expect(other.start, equals(builder.start));
    expect(other.remaining, equals(builder.remaining));
  });

  group('sort', () {
    test('sort_alphabetical', () {
      final result = builder
          .suggest('2')
          .suggest('4')
          .suggest('6')
          .suggest('8')
          .suggest('30')
          .suggest('32')
          .build();
      final actual = result.list.map((suggestion) => suggestion.text).toList();

      expect(actual, equals(['2', '30', '32', '4', '6', '8']));
    });

    test('sort_numerical', () {
      final result = builder
          .suggest(2)
          .suggest(4)
          .suggest(6)
          .suggest(8)
          .suggest(30)
          .suggest(32)
          .build();
      final actual = result.list.map((suggestion) => suggestion.text).toList();

      expect(actual, equals(['2', '4', '6', '8', '30', '32']));
    });

    test('sort_mixed', () {
      final result = builder
          .suggest('11')
          .suggest('22')
          .suggest('33')
          .suggest('a')
          .suggest('b')
          .suggest('c')
          .suggest(2)
          .suggest(4)
          .suggest(6)
          .suggest(8)
          .suggest(30)
          .suggest(32)
          .suggest('3a')
          .suggest('a3')
          .build();
      final actual = result.list.map((suggestion) => suggestion.text).toList();

      expect(
          actual,
          equals([
            '11',
            '2',
            '22',
            '33',
            '4',
            '6',
            '8',
            '30',
            '32',
            '3a',
            'a',
            'a3',
            'b',
            'c',
          ]));
    });
  });
}
