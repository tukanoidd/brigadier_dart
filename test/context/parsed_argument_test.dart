import 'package:test/test.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

void main() {
  test('testEquals', () {
    expect(ParsedArgument(0, 3, 'bar'), equals(ParsedArgument(0, 3, 'bar')));
    expect(ParsedArgument(3, 6, 'baz'), equals(ParsedArgument(3, 6, 'baz')));
    expect(ParsedArgument(6, 9, 'baz'), equals(ParsedArgument(6, 9, 'baz')));
  });
  
  test('getRaw', () {
    final reader = StringReader('0123456789');
    final argument = ParsedArgument(2, 5, '');
    
    expect(argument.range.getFromReader(reader), equals('234'));
  });
}