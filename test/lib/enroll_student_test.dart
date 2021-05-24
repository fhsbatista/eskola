import 'package:eskola/cpf_validator_impl.dart';
import 'package:eskola/enroll_student.dart';
import 'package:eskola/errors.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final enrollStudent = EnrollStudent(cpfValidator: CPFValidatorImpl());
  final validName = 'Fernando Batista';
  final validCpf = '383.916.398-60';

  test('should not enroll when students name is only one word', () {
    final request = EnrollRequest(student: Student(name: 'Fernando', cpf: validCpf));
    final call = () => enrollStudent.call(request);
    expect(call, throwsA(isA<InvalidName>()));
  });

  test('should not enroll when students name contains numbers', () {
    final request = EnrollRequest(
      student: Student(
        name: 'Fernando Henrique Silva B4t1st4',
        cpf: validCpf,
      ),
    );
    final call = () => enrollStudent.call(request);
    expect(call, throwsA(isA<InvalidName>()));
  });

  test('should not enroll when students name contains special chars', () {
    final request = EnrollRequest(
      student: Student(
        name: 'Fernando Henrique_Silva Batista',
        cpf: validCpf,
      ),
    );
    final call = () => enrollStudent.call(request);
    expect(call, throwsA(isA<InvalidName>()));
  });

  test('should enroll when students name is valid', () {
    final request = EnrollRequest(
      student: Student(
        name: 'Fernando Henrique Silva Batista',
        cpf: validCpf,
      ),
    );
    final result = enrollStudent(request);
    expect(result, isA<String>());
  });

  test('should not enroll when students cpf is invalid', () {
    final request = EnrollRequest(
      student: Student(
        name: validName,
        cpf: '123.123.123.01',
      ),
    );
    final call = () => enrollStudent.call(request);
    expect(call, throwsA(isA<InvalidCpf>()));
  });

  test('should not enroll when students cpf is one of the black list cpfs', () {
    final request = EnrollRequest(
      student: Student(
        name: validName,
        cpf: '555.555.555-55',
      ),
    );
    final call = () => enrollStudent.call(request);
    expect(call, throwsA(isA<InvalidCpf>()));
  });

  test('should enroll when students cpf is valid', () {
    final request = EnrollRequest(
      student: Student(
        name: validName,
        cpf: '383.916.398-60',
      ),
    );
    final result = enrollStudent(request);
    expect(result, isA<String>());
  });
}
