import 'package:test/test.dart';

import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:brigadier_dart/brigadier_dart.dart';

import 'bool_argument_type_test.mocks.dart';

@GenerateMocks([StringReader])
void main() {
  BoolArgumentType? type;

  setUp(() {
    type = BoolArgumentType();
  });

  test('parse', () {
    final reader = MockStringReader();
    when(reader.readBool()).thenReturn(true);
    expect(type!.parse(reader), equals(true));
    verify(reader.readBool());
  });
}