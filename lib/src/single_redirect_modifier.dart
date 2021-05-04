import 'package:brigadier_dart/src/context/command_context.dart';

abstract class SingleRedirectModifier<T> {
  T apply(CommandContext<T?> context);
}