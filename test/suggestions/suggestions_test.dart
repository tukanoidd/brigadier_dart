import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  group('merge', () {
    test('merge_empty', () {
      final merged = Suggestions.merge('foo b', []);
      expect(merged.isEmpty, equals(true));
    });

    test('merge_single', () {
      final suggestions = Suggestions(
        StringRange.at(5),
        [Suggestion(StringRange.at(5), 'ar')],
      );
      final merged = Suggestions.merge('foo b', [suggestions]);

      expect(merged, equals(suggestions));
    });

    test('merge_multiple', () {
      final a = Suggestions(
        StringRange.at(5),
        [
          Suggestion(StringRange.at(5), 'ar'),
          Suggestion(StringRange.at(5), 'az'),
          Suggestion(StringRange.at(5), 'Az'),
        ],
      );
      final b = Suggestions(
        StringRange.between(4, 5),
        [
          Suggestion(StringRange.between(4, 5), 'foo'),
          Suggestion(StringRange.between(4, 5), 'qux'),
          Suggestion(StringRange.between(4, 5), 'apple'),
          Suggestion(StringRange.between(4, 5), 'Bar'),
        ],
      );
      final merged = Suggestions.merge('foo b', [a, b]);

      expect(
          merged.list,
          equals(
            [
              Suggestion(StringRange.between(4, 5), 'apple'),
              Suggestion(StringRange.between(4, 5), 'bar'),
              Suggestion(StringRange.between(4, 5), 'Bar'),
              Suggestion(StringRange.between(4, 5), 'baz'),
              Suggestion(StringRange.between(4, 5), 'bAz'),
              Suggestion(StringRange.between(4, 5), 'foo'),
              Suggestion(StringRange.between(4, 5), 'qux'),
            ],
          ));
    });
  });
}
