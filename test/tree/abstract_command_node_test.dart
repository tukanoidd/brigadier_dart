import 'dart:collection';

import 'package:meta/meta.dart';

import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

abstract class AbstractCommandNodeTest {
  final Command _command = (context) => 1;

  @protected
  CommandNode get commandNode;

  void testCommandNode() {
    group('testAddChild', () {
      test('testAddChild', () {
        final node = commandNode;

        node.addChild(LiteralArgumentBuilder('child1').build());
        node.addChild(LiteralArgumentBuilder('child2').build());
        node.addChild(LiteralArgumentBuilder('child1').build());

        expect(node.children.length, equals(2));
      });

      test('testAddChildMergesGrandchildren', () {
        final node = commandNode;

        node.addChild(
          LiteralArgumentBuilder('child')
              .thenBuilder(LiteralArgumentBuilder('grandchild1'))
              .build(),
        );
        node.addChild(
          LiteralArgumentBuilder('child')
              .thenBuilder(LiteralArgumentBuilder('grandchild2'))
              .build(),
        );

        expect(node.children.length, equals(1));
        expect(
          HasNextIterator(node.children.iterator).next().children.length,
          equals(2),
        );
      });

      test('testAddChildPreservesCommand', () {
        final node = commandNode;

        node.addChild(
          LiteralArgumentBuilder('child').executes(_command).build(),
        );
        node.addChild(LiteralArgumentBuilder('child').build());

        expect(
          HasNextIterator(node.children.iterator).next().command,
          equals(_command),
        );
      });

      test('testAddChildOverwritesCommand', () {
        final node = commandNode;

        node.addChild(LiteralArgumentBuilder('child').build());
        node.addChild(
          LiteralArgumentBuilder('child').executes(_command).build(),
        );

        expect(
          HasNextIterator(node.children.iterator).next().command,
          equals(_command),
        );
      });
    });
  }

  Command get command => _command;
}
