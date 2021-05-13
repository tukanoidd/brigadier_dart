import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

class ParsingBenchmark extends BenchmarkBase {
  late CommandDispatcher _subject;

  ParsingBenchmark() : super('Parsing');

  static void main() => ParsingBenchmark().report();

  @override
  void setup() {
    _subject = CommandDispatcher();
    _subject.register(
      LiteralArgumentBuilder('a')
          .thenBuilder(
            LiteralArgumentBuilder('1')
                .thenBuilder(LiteralArgumentBuilder('i').executes((c) => 0))
                .thenBuilder(LiteralArgumentBuilder('ii').executes((c) => 0)),
          )
          .thenBuilder(
            LiteralArgumentBuilder('2')
                .thenBuilder(LiteralArgumentBuilder('i').executes((c) => 0))
                .thenBuilder(LiteralArgumentBuilder('ii').executes((c) => 0)),
          ),
    );
    _subject.register(
      LiteralArgumentBuilder('b')
          .thenBuilder(LiteralArgumentBuilder('1').executes((c) => 0)),
    );
    _subject.register(LiteralArgumentBuilder('c').executes((c) => 0));
    _subject.register(
      LiteralArgumentBuilder('d').requires((s) => false).executes((c) => 0),
    );
    _subject.register(
      LiteralArgumentBuilder('e').executes((c) => 0).thenBuilder(
            LiteralArgumentBuilder('1')
                .executes((c) => 0)
                .thenBuilder(LiteralArgumentBuilder('i').executes((c) => 0))
                .thenBuilder(LiteralArgumentBuilder('ii').executes((c) => 0)),
          ),
    );
    _subject.register(
      LiteralArgumentBuilder('f')
          .thenBuilder(
            LiteralArgumentBuilder('1')
                .thenBuilder(LiteralArgumentBuilder('i').executes((c) => 0))
                .thenBuilder(
                  LiteralArgumentBuilder('ii')
                      .executes((c) => 0)
                      .requires((s) => false),
                ),
          )
          .thenBuilder(
            LiteralArgumentBuilder('2')
                .thenBuilder(LiteralArgumentBuilder('i')
                    .executes((c) => 0)
                    .requires((s) => false))
                .thenBuilder(LiteralArgumentBuilder('ii').executes((c) => 0)),
          ),
    );
    _subject.register(
      LiteralArgumentBuilder('g').executes((c) => 0).thenBuilder(
            LiteralArgumentBuilder('1')
                .thenBuilder(LiteralArgumentBuilder('i').executes((c) => 0)),
          ),
    );
    final h = _subject.register(
      LiteralArgumentBuilder('h')
          .executes((c) => 0)
          .thenBuilder(
            LiteralArgumentBuilder('1')
                .thenBuilder(LiteralArgumentBuilder('i').executes((c) => 0)),
          )
          .thenBuilder(
            LiteralArgumentBuilder('2').thenBuilder(
              LiteralArgumentBuilder('i')
                  .thenBuilder(LiteralArgumentBuilder('ii').executes((c) => 0)),
            ),
          )
          .thenBuilder(LiteralArgumentBuilder('3').executes((c) => 0)),
    );
    _subject.register(
      LiteralArgumentBuilder('i')
          .executes((c) => 0)
          .thenBuilder(LiteralArgumentBuilder('1').executes((c) => 0))
          .thenBuilder(LiteralArgumentBuilder('2').executes((c) => 0)),
    );
    _subject.register(LiteralArgumentBuilder('j').redirect(_subject.root));
    _subject.register(LiteralArgumentBuilder('k').redirect(h));
  }

  @override
  void run() {
    _subject.parseString('a 1 i', Object());
    _subject.parseString('c', Object());
    _subject.parseString('k 1 i', Object());
    _subject.parseString('c', Object());
  }
}

void main() => ParsingBenchmark.main();
