import 'package:test/test.dart';

import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'argument_builder_test.mocks.dart';

class _TestableArgumentBuilder<T>
    extends ArgumentBuilder<T, _TestableArgumentBuilder<T>> {
  @override
  _TestableArgumentBuilder<T> getThis() => this;

  @override
  CommandNode<T>? build() => null;
}

@GenerateMocks([CommandNode])
void main() {
  _TestableArgumentBuilder? builder;

  setUp(() {
    builder = _TestableArgumentBuilder();
  });

  test('testArguments', () {
    final argument = RequiredArgumentBuilder('bar', IntegerArgumentType());

    builder!.thenBuilder(argument);

    expect(builder!.arguments.length, equals(1));
    expect(builder!.arguments.contains(argument.build()), equals(true));
  });

  group('testRedirect', () {
    test('testRedirect', () {
      final target = MockCommandNode();

      builder!.redirect(target);
      expect(builder!.redirected, equals(target));
    });

    test('testRedirect_withChild', () {
      expect(
        () {
          final target = MockCommandNode();

          builder!.thenBuilder(LiteralArgumentBuilder('foo'));
          builder!.redirect(target);
        },
        throwsException,
      );
    });

    test('testRedirect_withRedirect', () {
      expect(
        () {
          final target = MockCommandNode();

          builder!.redirect(target);
          builder!.thenBuilder(LiteralArgumentBuilder('foo'));
        },
        throwsException,
      );
    });
  });
}
