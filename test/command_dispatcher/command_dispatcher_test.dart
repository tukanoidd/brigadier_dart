import 'package:test/test.dart';

import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'command_dispatcher_test.mocks.dart';

@GenerateMocks([Object])
void main() {
  late CommandDispatcher subject;

  final command = (context) => 42;
  final source = MockObject();

  StringReader inputWithOffset(final String input, final int offset) {
    final result = StringReader(input);
    result.cursor = offset;

    return result;
  }

  setUp(() {
    subject = CommandDispatcher();
  });

  group('testCreateAndExecute', () {
    test('testCreateAndExecuteCommand', () {
      subject.register(LiteralArgumentBuilder('foo').executes(command));

      expect(subject.executeString('foo', source), equals(42));
    });

    test('testCreateAndExecuteOffsetCommand', () {
      subject.register(LiteralArgumentBuilder('foo').executes(command));

      expect(
        subject.executeReader(inputWithOffset('/foo', 1), source),
        equals(42),
      );
    });
  });

  test('testCreateAndMergeCommands', () {
    subject.register(
      LiteralArgumentBuilder('base').thenBuilder(
        LiteralArgumentBuilder('foo').executes(command),
      ),
    );
    subject.register(
      LiteralArgumentBuilder('base').thenBuilder(
        LiteralArgumentBuilder('bar').executes(command),
      ),
    );

    expect(subject.executeString('base foo', source), equals(42));
    expect(subject.executeString('base bar', source), equals(42));
  });

  group('testExecute', () {
    test('testExecuteUnknownCommand', () {
      subject.register(LiteralArgumentBuilder('bar'));
      subject.register(LiteralArgumentBuilder('baz'));

      expect(
        () => subject.executeString('foo', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownCommand &&
            ex.cursor == 0),
      );
    });

    test('testExecuteImpermequalssibleCommand', () {
      subject.register(LiteralArgumentBuilder('foo').requires((s) => false));

      expect(
        () => subject.executeString('foo', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownCommand &&
            ex.cursor == 0),
      );
    });

    test('testExecuteEmptyCommand', () {
      subject.register(LiteralArgumentBuilder(''));

      expect(
        () => subject.executeString('', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownCommand &&
            ex.cursor == 0),
      );
    });

    test('testExecuteEmptySubCommand', () {
      subject.register(LiteralArgumentBuilder('foo').executes(command));

      expect(
        () => subject.executeString('foo bar', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownArgument &&
            ex.cursor == 4),
      );
    });

    test('testExecutesIncorrectLiteral', () {
      subject.register(
        LiteralArgumentBuilder('foo')
            .executes(command)
            .thenBuilder(LiteralArgumentBuilder('bar')),
      );

      expect(
        () => subject.executeString('foo baz', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownArgument &&
            ex.cursor == 4),
      );
    });

    test('testExecuteAmbiguousIncorrectArgument', () {
      subject.register(
        LiteralArgumentBuilder('foo')
            .executes(command)
            .thenBuilder(LiteralArgumentBuilder('bar'))
            .thenBuilder(LiteralArgumentBuilder('baz')),
      );

      expect(
        () => subject.executeString('foo unknown', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownArgument &&
            ex.cursor == 4),
      );
    });

    test('testExecuteSubCommand', () {
      final subCommand = (context) => 100;

      subject.register(
        LiteralArgumentBuilder('foo')
            .thenBuilder(LiteralArgumentBuilder('a'))
            .thenBuilder(LiteralArgumentBuilder('=').executes(subCommand))
            .thenBuilder(LiteralArgumentBuilder('c'))
            .executes(command),
      );

      expect(subject.executeString('foo =', source), equals(100));
    });

    test('testExecuteAmbiguousParentSubcommand', () {
      final subCommand = (context) => 100;

      subject.register(
        LiteralArgumentBuilder('test')
            .thenBuilder(
              RequiredArgumentBuilder('incorrect', IntegerArgumentType())
                  .executes(command),
            )
            .thenBuilder(
              RequiredArgumentBuilder('right', IntegerArgumentType())
                  .thenBuilder(
                RequiredArgumentBuilder('sub', IntegerArgumentType())
                    .executes(subCommand),
              ),
            ),
      );

      expect(subject.executeString('test 1 2', source), equals(100));
    });

    test('testExecuteAmbiguousParentSubcommandViaRedirect', () {
      final subCommand = (context) => 100;

      final real = subject.register(
        LiteralArgumentBuilder('test')
            .thenBuilder(
              RequiredArgumentBuilder('incorrect', IntegerArgumentType())
                  .executes(command),
            )
            .thenBuilder(
              RequiredArgumentBuilder('right', IntegerArgumentType())
                  .thenBuilder(
                RequiredArgumentBuilder('sub', IntegerArgumentType())
                    .executes(subCommand),
              ),
            ),
      );

      subject.register(LiteralArgumentBuilder('redirect').redirect(real));

      expect(subject.executeString('test 1 2', source), equals(100));
    });

    test('testExecuteRedirectedMultipleTimes', () {
      final concreteNode = subject.register(
        LiteralArgumentBuilder('actual').executes(command),
      );
      final redirectNode = subject.register(
        LiteralArgumentBuilder('redirected').redirect(subject.root),
      );

      final input = 'redirected redirected actual';

      final parse = subject.parseString(input, source);
      expect(parse.context.range.getFromString(input), equals('redirected'));
      expect(parse.context.nodes.length, equals(1));
      expect(parse.context.rootNode, equals(subject.root));
      expect(parse.context.nodes[0].range, equals(parse.context.range));
      expect(parse.context.nodes[0].node, equals(redirectNode));

      final child1 = parse.context.child;
      expect(child1 != null, equals(true));
      expect(child1!.range.getFromString(input), equals('redirected'));
      expect(child1.nodes.length, equals(1));
      expect(child1.rootNode, equals(subject.root));
      expect(child1.nodes[0].range, equals(child1.range));
      expect(child1.nodes[0].node, equals(redirectNode));

      final child2 = child1.child;
      expect(child2 != null, equals(true));
      expect(child2!.range.getFromString(input), equals('actual'));
      expect(child2.nodes.length, equals(1));
      expect(child2.rootNode, equals(subject.root));
      expect(child2.nodes[0].range, equals(child2.range));
      expect(child2.nodes[0].node, equals(concreteNode));

      expect(subject.executeParse(parse), equals(42));
    });

    test('testExecuteRedirected', () {
      final source1 = Object();
      final source2 = Object();
      final RedirectModifier modifier = (context) => [source1, source2];

      final concreteNode = subject.register(
        LiteralArgumentBuilder('actual').executes(command),
      );
      final redirectNode = subject.register(
        LiteralArgumentBuilder('redirected').fork(subject.root, modifier),
      );

      final input = 'redirected actual';
      final parse = subject.parseString(input, source);
      expect(parse.context.range.getFromString(input), equals('redirected'));
      expect(parse.context.nodes.length, equals(1));
      expect(parse.context.rootNode, equals(subject.root));
      expect(parse.context.nodes[0].range, equals(parse.context.range));
      expect(parse.context.nodes[0].node, equals(redirectNode));
      expect(parse.context.source, equals(source));

      final parent = parse.context.child;
      expect(parent != null, equals(true));
      expect(parent!.range.getFromString(input), equals('actual'));
      expect(parent.nodes.length, equals(1));
      expect(parse.context.rootNode, equals(subject.root));
      expect(parent.nodes[0].range, equals(parent.range));
      expect(parent.nodes[0].node, equals(concreteNode));
      expect(parent.source, equals(source));

      expect(subject.executeParse(parse), equals(2));
    });

    test('testExecuteOrphanedSubcommand', () {
      subject.register(
        LiteralArgumentBuilder('foo')
            .thenBuilder(RequiredArgumentBuilder('bar', IntegerArgumentType()))
            .executes(command),
      );

      expect(
        () => subject.executeString('foo 5', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownCommand &&
            ex.cursor == 5),
      );
    });

    test('testExecute_invalidOther', () {
      final wrongCommand = (context) => 0;

      subject.register(LiteralArgumentBuilder('w').executes(wrongCommand));
      subject.register(LiteralArgumentBuilder('world').executes(command));

      expect(subject.executeString('world', source), equals(42));
    });

    test('testExecuteInvalidSubcommand', () {
      subject.register(
        LiteralArgumentBuilder('foo')
            .thenBuilder(RequiredArgumentBuilder('bar', IntegerArgumentType()))
            .executes(command),
      );

      expect(
        () => subject.executeString('foo bar', source),
        throwsA(
          (ex) =>
              ex is CommandSyntaxException &&
              ex.type ==
                  CommandSyntaxException
                      .BUILT_IN_EXCEPTIONS.dispatcherParseException &&
              ex.cursor == 4,
        ),
      );
    });
  });

  group('testParse', () {
    test('testParseIncompleteLiteral', () {
      subject.register(
        LiteralArgumentBuilder('foo')
            .thenBuilder(LiteralArgumentBuilder('bar').executes(command)),
      );

      final parse = subject.parseString('foo ', source);

      expect(parse.reader.remaining, equals(' '));
      expect(parse.context.nodes.length, equals(1));
    });

    test('testParseIncompleteArgument', () {
      subject.register(
        LiteralArgumentBuilder('foo')
            .thenBuilder(RequiredArgumentBuilder('bar', IntegerArgumentType()))
            .executes(command),
      );

      final parse = subject.parseString('foo ', source);

      expect(parse.reader.remaining, equals(' '));
      expect(parse.context.nodes.length, equals(1));
    });

    test('testParse_noSpaceSeparator', () {
      subject.register(
        LiteralArgumentBuilder('foo').thenBuilder(
            RequiredArgumentBuilder('bar', IntegerArgumentType())
                .executes(command)),
      );

      expect(
        () => subject.executeString('foo\$', source),
        throwsA((ex) =>
            ex is CommandSyntaxException &&
            ex.type ==
                CommandSyntaxException
                    .BUILT_IN_EXCEPTIONS.dispatcherUnknownCommand &&
            ex.cursor == 0),
      );
    });
  });

  test('testGetPath', () {
    final bar = LiteralArgumentBuilder('bar').build();
    subject.register(LiteralArgumentBuilder('foo').thenCommand(bar));
    
    expect(subject.getPath(bar), equals(['foo', 'bar']));
  });
  
  test('testFindNodeExists', () {
    final bar = LiteralArgumentBuilder('bar').build();
    subject.register(LiteralArgumentBuilder('foo').thenCommand(bar));
    
    expect(subject.findNode(['foo', 'bar']), equals(bar));
  });

  test('testFindNodeDoesntExist', () {
    expect(subject.findNode(['foo', 'bar']), equals(null));
  });
}
