import 'package:brigadier_dart/src/tree/command_node.dart';

class SuggestionContext<T> {
  final CommandNode<T>? parent;
  final int startPos;

  SuggestionContext(this.parent, this.startPos);
}