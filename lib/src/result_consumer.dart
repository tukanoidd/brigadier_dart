import 'package:brigadier_dart/src/context/context.dart';

typedef ResultConsumer<T> = void Function(CommandContext<T> context, bool success, int result);