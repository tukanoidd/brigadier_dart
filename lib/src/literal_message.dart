import 'message.dart';

class LiteralMessage implements Message {
  final String _string;

  LiteralMessage(final String string): _string = string;

  @override
  String get string => _string;

  @override
  String toString() => _string;
}