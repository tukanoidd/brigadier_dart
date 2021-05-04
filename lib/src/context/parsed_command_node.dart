import 'package:brigadier_dart/src/context/context.dart';
import 'package:brigadier_dart/src/tree/command_node.dart';
import 'package:quiver/core.dart';

class ParsedCommandNode<T> {
  final CommandNode<T>? _node;

  final StringRange _range;

  ParsedCommandNode(CommandNode<T> node, StringRange range)
      : _node = node,
        _range = range;

  CommandNode<T>? get node => _node;

  StringRange get range => _range;

  @override
  String toString() => '$_node@$_range';

  @override
  bool operator ==(Object other) {
    if (this == other) return true;

    if (!(other is ParsedCommandNode)) return false;

    return _node == other._node && _range == other._range;
  }

  @override
  int get hashCode => hash2(_node, _range);
}
