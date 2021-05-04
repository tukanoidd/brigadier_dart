import 'context/command_context.dart';

typedef RedirectModifier<T> = Iterable<T> Function(CommandContext<T> context);