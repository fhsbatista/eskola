import 'package:eskola/cpf.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('should throw invalid cpf valid cpf correctly', () {
    expect(() => Cpf('00000000000'), throwsA(isA<InvalidCpf>()));
    expect(() => Cpf('86446422799'), throwsA(isA<InvalidCpf>()));
  });
  test('should instantiate cpf with no problems', () {
    expect(Cpf('38391639860'), isA<Cpf>());
    expect(Cpf('321.279.840-80'), isA<Cpf>());
    expect(Cpf('11627329030'), isA<Cpf>());
  });
}
