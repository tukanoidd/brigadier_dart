abstract class ImmutableStringReader {
  String get string;

  int get remainingLength;

  int get totalLength;

  int get cursor;

  String get read;

  String get remaining;

  bool canRead([int? length]);

  String peek([int? offset]);
}