import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

class ExecuteBenchmark extends BenchmarkBase {
  late CommandDispatcher _dispatcher;
  late ParseResults _simple;
  late ParseResults _singleRedirect;
  late ParseResults _forkedRedirect;

  ExecuteBenchmark() : super('Execute');

  static void main() => ExecuteBenchmark().report();

  @override
  void setup() {
    _dispatcher = CommandDispatcher();
    _dispatcher.register(LiteralArgumentBuilder('command').executes((c) => 0));
    _dispatcher.register(
      LiteralArgumentBuilder('redirect').redirect(_dispatcher.root),
    );
    _dispatcher.register(
      LiteralArgumentBuilder('fork')
          .fork(_dispatcher.root, (o) => [Object(), Object(), Object()]),
    );
    _simple = _dispatcher.parseString('command', Object());
    _singleRedirect = _dispatcher.parseString('redirect command', Object());
    _forkedRedirect = _dispatcher.parseString('fork command', Object());
  }

  @override
  void run() {
    _dispatcher.executeParse(_simple);
    _dispatcher.executeParse(_singleRedirect);
    _dispatcher.executeParse(_forkedRedirect);
  }
}

void main() => ExecuteBenchmark.main();
