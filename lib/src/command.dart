import 'context/command_context.dart';

abstract class Command<T> {
  int SINGLE_SUCCESS = 1;

  int run(CommandContext<T> context);
}