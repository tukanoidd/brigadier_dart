import 'context/command_context.dart';

typedef Command<T> = int Function(CommandContext<T>);