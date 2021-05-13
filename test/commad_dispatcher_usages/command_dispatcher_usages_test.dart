import 'package:test/test.dart';

import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'command_dispatcher_usages_test.mocks.dart';

@GenerateMocks([Object])
void main() {
  CommandDispatcher? subject;
  final source = MockObject();
  final command = (context) => 0;

  CommandNode? getString(final String command) =>
      subject!.parseString(command, source).context.nodes.last.node;

  CommandNode? getReader(final StringReader command) =>
      subject!.parseReader(command, source).context.nodes.last.node;

  setUp(() {
    subject = CommandDispatcher();
    subject!.register(
      LiteralArgumentBuilder('a')
          .thenBuilder(
            LiteralArgumentBuilder('1')
                .thenBuilder(LiteralArgumentBuilder('i').executes(command))
                .thenBuilder(LiteralArgumentBuilder('ii').executes(command)),
          )
          .thenBuilder(
            LiteralArgumentBuilder('2')
                .thenBuilder(LiteralArgumentBuilder('i').executes(command))
                .thenBuilder(LiteralArgumentBuilder('ii').executes(command)),
          ),
    );
    subject!.register(
      LiteralArgumentBuilder('b')
          .thenBuilder(LiteralArgumentBuilder('1').executes(command)),
    );
    subject!.register(LiteralArgumentBuilder('c').executes(command));
    subject!.register(
      LiteralArgumentBuilder('d').requires((s) => false).executes(command),
    );
    subject!.register(
      LiteralArgumentBuilder('e').executes(command).thenBuilder(
            LiteralArgumentBuilder('1')
                .executes(command)
                .thenBuilder(LiteralArgumentBuilder('i').executes(command))
                .thenBuilder(LiteralArgumentBuilder('ii').executes(command)),
          ),
    );
    subject!.register(
      LiteralArgumentBuilder('f')
          .thenBuilder(
            LiteralArgumentBuilder('1')
                .thenBuilder(LiteralArgumentBuilder('i').executes(command))
                .thenBuilder(
                  LiteralArgumentBuilder('ii')
                      .executes(command)
                      .requires((s) => false),
                ),
          )
          .thenBuilder(
            LiteralArgumentBuilder('2')
                .thenBuilder(LiteralArgumentBuilder('i')
                    .executes(command)
                    .requires((s) => false))
                .thenBuilder(LiteralArgumentBuilder('ii').executes(command)),
          ),
    );
    subject!.register(
      LiteralArgumentBuilder('g').executes(command).thenBuilder(
            LiteralArgumentBuilder('1')
                .thenBuilder(LiteralArgumentBuilder('i').executes(command)),
          ),
    );
    subject!.register(LiteralArgumentBuilder('h')
        .executes(command)
        .thenBuilder(
          LiteralArgumentBuilder('1')
              .thenBuilder(LiteralArgumentBuilder('i').executes(command)),
        )
        .thenBuilder(
          LiteralArgumentBuilder('2').thenBuilder(
            LiteralArgumentBuilder('i')
                .thenBuilder(LiteralArgumentBuilder('ii').executes(command)),
          ),
        )
        .thenBuilder(LiteralArgumentBuilder('3').executes(command)));
    subject!.register(
      LiteralArgumentBuilder('i')
          .executes(command)
          .thenBuilder(LiteralArgumentBuilder('1').executes(command))
          .thenBuilder(LiteralArgumentBuilder('2').executes(command)),
    );
    subject!.register(LiteralArgumentBuilder('j').redirect(subject!.root));
    subject!.register(LiteralArgumentBuilder('k').redirect(getString('h')!));
  });

  group('testUsage', () {
    test('testAllUsage_noCommands', () {
      subject = CommandDispatcher();

      final results = subject!.getAllUsage(subject!.root, source, true);

      expect(results.isEmpty, equals(true));
    });

    test('testSmartUsage_noCommands', () {
      subject = CommandDispatcher();

      final results = subject!.getSmartUsage(subject!.root, source);

      expect(results.isEmpty, equals(true));
    });

    test('testAllUsage_root', () {
      final results = subject!.getAllUsage(subject!.root, source, true);
      expect(
          results,
          equals([
            'a 1 i',
            'a 1 ii',
            'a 2 i',
            'a 2 ii',
            'b 1',
            'c',
            'e',
            'e 1',
            'e 1 i',
            'e 1 ii',
            'f 1 i',
            'f 2 ii',
            'g',
            'g 1 i',
            'h',
            'h 1 i',
            'h 2 i ii',
            'h 3',
            'i',
            'i 1',
            'i 2',
            'j ...',
            'k -> h',
          ]));
    });

    test('testSmartUsage_root', () {
      final results = subject!.getSmartUsage(subject!.root, source);
      expect(
        results,
        equals({
          getString('a'): 'a (1|2)',
          getString('b'): 'b 1',
          getString('c'): 'c',
          getString('e'): 'e [1]',
          getString('f'): 'f (1|2)',
          getString('g'): 'g [1]',
          getString('h'): 'h [1|2|3]',
          getString('i'): 'i [1|2]',
          getString('j'): 'j ...',
          getString('k'): 'k -> h',
        }),
      );
    });

    test('testSmartUsage_h', () {
      final results = subject!.getSmartUsage(getString('h')!, source);
      expect(
        results,
        equals({
          getString('h 1'): '[1] i',
          getString('h 2'): '[2] i ii',
          getString('h 3'): '[3]',
        }),
      );
    });

    test('testSmartUsage_offsetH', () {
      final offsetH = StringReader('/|/|/h');
      offsetH.cursor = 5;

      final results = subject!.getSmartUsage(getReader(offsetH)!, source);
      expect(
        results,
        equals({
          getString('h 1'): '[1] i',
          getString('h 2'): '[2] i ii',
          getString('h 3'): '[3]',
        }),
      );
    });
  });
}
