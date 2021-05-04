import 'package:brigadier_dart/src/context/command_context_builder.dart';
import 'package:brigadier_dart/src/string_reader.dart';
import 'package:brigadier_dart/src/tree/command_node.dart';

import 'exceptions/exceptions.dart';
import 'immutable_string_reader.dart';

class ParseResults<T> {
  final CommandContextBuilder<T> _context;
  final Map<CommandNode<T>, CommandSyntaxException> _exceptions;
  final ImmutableStringReader _reader;

  ParseResults(
    final CommandContextBuilder<T> context, [
    final ImmutableStringReader? reader,
    final Map<CommandNode<T>, CommandSyntaxException>? exceptions,
  ])  : _context = context,
        _reader = reader ?? StringReader(''),
        _exceptions = exceptions ?? {};

  CommandContextBuilder<T> get context => _context;

  ImmutableStringReader get reader => _reader;

  Map<CommandNode<T>, CommandSyntaxException> get exceptions => _exceptions;
}
