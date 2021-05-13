import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  group('apply_insertation', () {
    test('apply_insertation_start', () {
      final suggestion = Suggestion(StringRange.at(0), 'And so I said: ');
      expect(suggestion.apply('Hello world!'),
          equals('And so I said: Hello world!'));
    });

    test('apply_insertation_middle', () {
      final suggestion = Suggestion(StringRange.at(6), 'small ');
      expect(suggestion.apply('Hello world!'), equals('Hello small world!'));
    });

    test('apply_insertation_end', () {
      final suggestion = Suggestion(StringRange.at(5), ' world!');
      expect(suggestion.apply('Hello'), equals('Hello world!'));
    });
  });

  group('apply_replacement', () {
    test('apply_replacement_start', () {
      final suggestion = Suggestion(StringRange.between(0, 5), 'Goodbye');
      expect(suggestion.apply('Hello world!'), equals('Goodbye world!'));
    });

    test('apply_replacement_middle', () {
      final suggestion = Suggestion(StringRange.between(6, 11), 'Alex');
      expect(suggestion.apply('Hello world!'), equals('Hello Alex!'));
    });

    test('apply_replacement_end', () {
      final suggestion = Suggestion(StringRange.between(6, 12), 'Creeper!');
      expect(suggestion.apply('Hello world!'), equals('Hello Creeper!'));
    });

    test('apply_replacement_everything', () {
      final suggestion = Suggestion(StringRange.between(0, 12), 'Oh dear.');
      expect(suggestion.apply('Hello world!'), equals('Oh dear.'));
    });
  });

  group('expand', () {
    test('expand_unchanged', () {
      final suggestion = Suggestion(StringRange.at(1), 'oo');
      expect(suggestion.expand('f', StringRange.at(1)), equals(suggestion));
    });

    test('expand_left', () {
      final suggestion = Suggestion(StringRange.at(1), 'oo');
      expect(
        suggestion.expand('f', StringRange.between(0, 1)),
        equals(Suggestion(StringRange.between(0, 1), 'foo')),
      );
    });

    test('expand_right', () {
      final suggestion = Suggestion(StringRange.at(0), 'minecraft:');
      expect(
        suggestion.expand('fish', StringRange.between(0, 4)),
        equals(Suggestion(StringRange.between(0, 4), 'minecraft:fish')),
      );
    });

    test('expand_both', () {
      final suggestion = Suggestion(StringRange.at(11), 'minecraft:');
      expect(
        suggestion.expand('give Steve fish_block', StringRange.between(5, 21)),
        equals(
          Suggestion(StringRange.between(5, 21), 'Steve minecraft:fish_block'),
        ),
      );
    });

    test('expand_replacement', () {
      final suggestion = Suggestion(StringRange.between(6, 11), 'strangers');
      expect(
        suggestion.expand('Hello world!', StringRange.between(0, 12)),
        equals(Suggestion(StringRange.between(0, 12), 'Hello strangers!')),
      );
    });
  });
}
