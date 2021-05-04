import 'tree/command_node.dart';

abstract class AmbiguityConsumer<T> {
  void ambiguous(
    final CommandNode<T> parent,
    final CommandNode<T> child,
    final CommandNode<T> sibling,
    final Iterable<String> inputs,
  );
}
