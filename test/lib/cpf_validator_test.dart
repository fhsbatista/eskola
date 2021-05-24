import 'package:eskola/cpf_validator_impl.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final cpfValidator = CPFValidatorImpl();
  test('should valid cpf correctly', () {
    expect(cpfValidator.isValid('00000000000'), false);
    expect(cpfValidator.isValid('86446422799'), false);
    expect(cpfValidator.isValid('86446422784'), true);
    expect(cpfValidator.isValid('864.464.227-84'), true);
    expect(cpfValidator.isValid('91720489726'), true);
  });
}
