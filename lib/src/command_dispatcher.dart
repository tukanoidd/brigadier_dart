import 'dart:collection';
import 'dart:math' as math;

import 'package:brigadier_dart/src/context/command_context.dart';
import 'package:brigadier_dart/src/exceptions/exceptions.dart';
import 'package:brigadier_dart/src/helpers.dart';
import 'package:brigadier_dart/src/result_consumer.dart';
import 'package:brigadier_dart/src/tree/root_command_node.dart';
import 'package:brigadier_dart/src/tree/tree.dart';

import 'ambiguity_consumer.dart';
import 'builder/literal_argument_builder.dart';
import 'context/context.dart';
import 'parse_results.dart';
import 'string_reader.dart';
import 'suggestion/all.dart';

class CommandDispatcher<T> {
  static final String ARGUMENT_SEPARATOR = ' ';

  static final String ARGUMENT_SEPARATOR_CHAR = ' ';

  static final String _USAGE_OPTIONAL_OPEN = '[';
  static final String _USAGE_OPTIONAL_CLOSE = ']';
  static final String _USAGE_REQUIRED_OPEN = '(';
  static final String _USAGE_REQUIRED_CLOSE = ')';
  static final String _USAGE_OR = '|';

  final RootCommandNode<T> _root;

  late final Predicate<CommandNode<T>> _hasCommand = (CommandNode<T>? input) =>
      input != null &&
      (input.command != null || input.children.any(_hasCommand));
  ResultConsumer<T> _consumer = (c, s, r) {};

  CommandDispatcher([final RootCommandNode<T>? root])
      : _root = root ?? RootCommandNode<T>();

  LiteralCommandNode<T> register(final LiteralArgumentBuilder<T> command) {
    final build = command.build();
    _root.addChild(build);

    return build;
  }

  set consumer(final ResultConsumer<T> consumer) => _consumer = consumer;

  int executeString(final String input, final T source) {
    return executeReader(StringReader(input), source);
  }

  int executeReader(final StringReader input, final T source) {
    final ParseResults<T> parse = parseReader(input, source);
    return executeParse(parse);
  }

  int executeParse(final ParseResults<T> parse) {
    if (parse.reader.canRead()) {
      if (parse.exceptions.length == 1) {
        throw parse.exceptions.values.first;
      } else if (parse.context.range.isEmpty) {
        throw CommandSyntaxException
            .BUILT_IN_EXCEPTIONS.dispatcherUnknownCommand
            .createWithContext(parse.reader);
      } else {
        throw CommandSyntaxException
            .BUILT_IN_EXCEPTIONS.dispatcherUnknownArgument
            .createWithContext(parse.reader);
      }
    }

    var result = 0;
    var successfulForks = 0;
    var forked = false;
    var foundCommand = false;
    final command = parse.reader.string;
    final original = parse.context.build(command);
    List<CommandContext<T>>? contexts = [original];
    List<CommandContext<T>>? next;

    while (contexts != null) {
      final size = contexts.length;

      for (var i = 0; i < size; i++) {
        final context = contexts[i];
        final child = context.child;

        if (child != null) {
          forked |= context.isForked;
          if (child.hasNodes) {
            foundCommand = true;
            final modifier = context.redirectModifier;

            if (modifier == null) {
              next ??= [];
              next.add(child.copyFor(context.source));
            } else {
              try {
                final results = modifier(context);
                if (results.isNotEmpty) {
                  next ??= [];
                  next.addAll(results.map((source) => child.copyFor(source)));
                }
              } on CommandSyntaxException {
                _consumer(context, false, 0);

                if (!forked) rethrow;
              }
            }
          }
        } else if (context.command != null) {
          foundCommand = true;

          try {
            final value = context.command!(context);
            result += value;
            _consumer(context, true, value);
            successfulForks++;
          } on CommandSyntaxException {
            _consumer(context, true, 0);

            if (!forked) rethrow;
          }
        }
      }

      contexts = next;
      next = null;
    }

    if (!foundCommand) {
      _consumer(original, false, 0);
      throw CommandSyntaxException.BUILT_IN_EXCEPTIONS.dispatcherUnknownCommand
          .createWithContext(parse.reader);
    }

    return forked ? successfulForks : result;
  }

  ParseResults<T> parseString(final String command, final T source) =>
      parseReader(StringReader(command), source);

  ParseResults<T> parseReader(final StringReader command, final T source) {
    final context = CommandContextBuilder<T>(
      this,
      source,
      _root,
      command.cursor,
    );

    return _parseNodes(_root, command, context);
  }

  ParseResults<T> _parseNodes(
      final CommandNode<T> node,
      final StringReader originalReader,
      final CommandContextBuilder<T> contextSoFar) {
    final source = contextSoFar.source;
    Map<CommandNode<T>, CommandSyntaxException>? errors;
    List<ParseResults<T>>? potentials;
    final cursor = originalReader.cursor;

    for (final CommandNode<T> child in node.getRelevantNodes(originalReader)) {
      if (!child.canUse(source)) continue;

      final context = contextSoFar.copy();
      final reader = StringReader.fromStringReader(originalReader);

      try {
        try {
          child.parse(reader, context);
        } catch (ex) {
          throw CommandSyntaxException
              .BUILT_IN_EXCEPTIONS.dispatcherParseException
              .createWithContext(reader, ex.toString());
        }

        if (reader.canRead()) {
          if (reader.peek() != ARGUMENT_SEPARATOR_CHAR) {
            throw CommandSyntaxException
                .BUILT_IN_EXCEPTIONS.dispatcherExpectedArgumentSeparator
                .createWithContext(reader);
          }
        }
      } on CommandSyntaxException catch (ex) {
        errors ??= {};

        errors[child] = ex;
        reader.cursor = cursor;

        continue;
      }

      context.withCommand(child.command);
      if (reader.canRead(child.redirect == null ? 2 : 1)) {
        reader.skip();

        if (child.redirect != null) {
          final childContext = CommandContextBuilder<T>(
              this, source, child.redirect!, reader.cursor);
          final parse = _parseNodes(child.redirect!, reader, childContext);

          context.withChild(parse.context);

          return ParseResults<T>(context, parse.reader, parse.exceptions);
        } else {
          final parse = _parseNodes(child, reader, context);
          potentials ??= [];

          potentials.add(parse);
        }
      } else {
        potentials ??= [];

        potentials.add(ParseResults<T>(context, reader, {}));
      }
    }

    if (potentials != null) {
      if (potentials.length > 1) {
        potentials.sort((a, b) {
          if (!a.reader.canRead() && b.reader.canRead()) return -1;
          if (a.reader.canRead() && !b.reader.canRead()) return 1;
          if (a.exceptions.isEmpty && b.exceptions.isNotEmpty) return -1;
          if (a.exceptions.isNotEmpty && b.exceptions.isEmpty) return 1;

          return 0;
        });
      }

      return potentials[0];
    }

    return ParseResults<T>(contextSoFar, originalReader, errors ?? {});
  }

  List<String> getAllUsage(
    final CommandNode<T> node,
    final T source,
    final bool restricted,
  ) {
    final result = <String>[];
    _getAllUsage(node, source, result, '', restricted);

    return result;
  }

  void _getAllUsage(
    final CommandNode<T> node,
    final T source,
    final List<String> result,
    final String prefix,
    final bool restricted,
  ) {
    if (restricted && !node.canUse(source)) return;

    if (node.command != null) result.add(prefix);

    if (node.redirect != null) {
      final redirect =
          '${node.redirect == _root ? '...' : '-> ${node.redirect!.usageText}'}';

      result.add(prefix.isEmpty
          ? '${node.usageText}$ARGUMENT_SEPARATOR$redirect'
          : '$prefix$ARGUMENT_SEPARATOR$redirect');
    } else if (node.children.isNotEmpty) {
      for (final child in node.children) {
        _getAllUsage(
          child,
          source,
          result,
          prefix.isEmpty
              ? child.usageText
              : '$prefix$ARGUMENT_SEPARATOR${child.usageText}',
          restricted,
        );
      }
    }
  }

  Map<CommandNode<T>, String> getSmartUsage(
    final CommandNode<T> node,
    final T source,
  ) {
    final result = <CommandNode<T>, String>{};

    final optional = node.command != null;
    for (final child in node.children) {
      final usage = _getSmartUsage(child, source, optional, false);

      if (usage != null) result[child] = usage;
    }

    return result;
  }

  String? _getSmartUsage(final CommandNode<T> node, final T source,
      final bool optional, final bool deep) {
    if (!node.canUse(source)) return null;

    final self = optional
        ? '$_USAGE_OPTIONAL_OPEN${node.usageText}$_USAGE_OPTIONAL_CLOSE'
        : node.usageText;
    final childOptional = node.command != null;
    final open = childOptional ? _USAGE_OPTIONAL_OPEN : _USAGE_REQUIRED_OPEN;
    final close = childOptional ? _USAGE_OPTIONAL_CLOSE : _USAGE_REQUIRED_CLOSE;

    if (!deep) {
      if (node.redirect != null) {
        final redirect =
            node.redirect == _root ? '...' : '-> ${node.redirect!.usageText}';

        return '$self$ARGUMENT_SEPARATOR$redirect';
      } else {
        final children = node.children.where((c) => c.canUse(source));

        if (children.length == 1) {
          final usage = _getSmartUsage(
              HasNextIterator(children.iterator).next(),
              source,
              childOptional,
              childOptional);

          if (usage != null) return '$self$ARGUMENT_SEPARATOR$usage';
        } else if (children.length > 1) {
          final childUsage = <String>{};

          for (final child in children) {
            final usage = _getSmartUsage(child, source, childOptional, true);

            if (usage != null) childUsage.add(usage);
          }

          if (childUsage.length == 1) {
            final usage = childUsage.first;

            return '$self$ARGUMENT_SEPARATOR${childOptional ? '$_USAGE_OPTIONAL_OPEN$usage$_USAGE_OPTIONAL_CLOSE}' : usage}';
          } else if (childUsage.length > 1) {
            final buffer = StringBuffer(open);
            var count = 0;

            for (final child in children) {
              if (count > 0) buffer.write(_USAGE_OR);

              buffer.write(child.usageText);
              count++;
            }

            if (count > 0) {
              buffer.write(close);

              return '$self$ARGUMENT_SEPARATOR${buffer.toString()}';
            }
          }
        }
      }
    }

    return self;
  }

  Future<Suggestions> getCompletionSuggestions(
    final ParseResults<T> parse, [
    int? cursor,
  ]) async {
    cursor ??= parse.reader.totalLength;

    final context = parse.context;

    final nodeBeforeCursor = context.findSuggestionContext(cursor);
    final parent = nodeBeforeCursor.parent;
    final start = math.min(nodeBeforeCursor.startPos, cursor);

    print('nodeBeforeCursor: $nodeBeforeCursor');
    print('parent: $parent');
    print('start: $start');

    final fullInput = parse.reader.string;
    final truncatedInput = fullInput.substring(0, cursor);
    final truncatedInputLowerCase = truncatedInput.toLowerCase();
    final futures = <Future<Suggestions>>[];

    if (parent != null) {
      for (final node in parent.children) {
        var future = Suggestions.empty;

        try {
          future = node.listSuggestions(
            context.build(truncatedInput),
            SuggestionsBuilder(
              truncatedInput,
              start,
              truncatedInputLowerCase,
            ),
          );

          print('future: $future');
          print('suggestionsBuilder: ${SuggestionsBuilder(
            truncatedInput,
            start,
            truncatedInputLowerCase,
          ).input}');
        } catch (ex) {
          print(ex.toString());
        }

        futures.add(future);
      }
    }

    print(futures);

    final suggestions = await Future.wait(futures);

    print('fullInput: $fullInput');
    print('suggestions: $suggestions');

    print('merged: ${Suggestions.merge(fullInput, suggestions)}');

    return Suggestions.merge(fullInput, suggestions);
  }

  RootCommandNode<T> get root => _root;

  Iterable<String> getPath(final CommandNode<T> target) {
    final nodes = <List<CommandNode<T>>>[];
    _addPaths(root, nodes, []);

    for (final list in nodes) {
      if (list.last == target) {
        final result = <String>[];

        for (final node in list) {
          if (node != _root) result.add(node.name);
        }

        return result;
      }
    }

    return [];
  }

  CommandNode<T>? findNode(final Iterable<String> path) {
    CommandNode<T>? node = _root;

    for (final name in path) {
      node = node?.getChild(name);

      if (node == null) return null;
    }

    return node;
  }

  void findAmbiguities(final AmbiguityConsumer<T> consumer) =>
      root.findAmbiguities(consumer);

  void _addPaths(
    final CommandNode<T> node,
    final List<List<CommandNode<T>>> result,
    final List<CommandNode<T>> parents,
  ) {
    final current = [...parents];
    current.add(node);
    result.add(current);

    for (final child in node.children) {
      _addPaths(child, result, current);
    }
  }
}
