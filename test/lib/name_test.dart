import 'package:eskola/name.dart';
import 'package:test/test.dart';

void main() {
  test('should throw invalid name', () {
    expect(() => Name('Fernando'), throwsA(isA<InvalidName>()));
    expect(() => Name('Fernando_Henrique'), throwsA(isA<InvalidName>()));
    expect(() => Name('Fer123'), throwsA(isA<InvalidName>()));
    expect(() => Name('fernando*henrique'), throwsA(isA<InvalidName>()));
  });
  test('should instantiate name with no problems', () {
    expect(Name('Fernando Henrique Silva Batista'), isA<Name>());
    expect(Name('Fernando Batista'), isA<Name>());
    expect(Name('Fulano da Silva'), isA<Name>());
  });
}
