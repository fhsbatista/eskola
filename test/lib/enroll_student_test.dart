import 'package:eskola/clazz.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/enroll_student.dart';
import 'package:eskola/level.dart';
import 'package:eskola/module.dart';
import 'package:eskola/name.dart';
import 'package:eskola/repository.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository repository;
  late EnrollStudent enrollStudent;

  setUpAll(() {
    repository = MockRepository();
    enrollStudent = EnrollStudent(repository: repository);
  });

  final validStudent = Student(
    name: Name('Fernando Batista'),
    cpf: Cpf('383.916.398-60'),
    birthDate: DateTime(1995, 11, 8),
  );

  test('should generate code for the enrolled student', () async {
    //arrange
    final lastEnrolledStudentCode = 12;
    when(() => repository.getLastEnrolledStudentCode())
        .thenAnswer((_) async => lastEnrolledStudentCode);
    final level = 'EM';
    final module = '1';
    final clazz = 'A';
    final request = EnrollRequest(
      student: validStudent,
      level: level,
      module: module,
      clazz: clazz,
    );

    //act
    final result = await enrollStudent(request);

    //assert
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    expect(result, '$currentYear$level$module$clazz${lastEnrolledStudentCode + 1}');
  });

  test('should throw InvalidAge when the age is less than minimum age', () {
    //TODO find a way to mock reference data to age calculation. Otherwise this test might misfunction in the future.
    //arrange
    final level = Level(code: 'EF', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 100,
    );
    final clazz = Clazz(level: level, module: module, code: '1', capacity: 20);
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: DateTime(2020, 11, 8),
    );
    final request = EnrollRequest(
      student: student,
      level: level.code,
      module: module.code,
      clazz: clazz.code,
    );
    when(() => repository.getLastEnrolledStudentCode()).thenAnswer((_) async => 1);
    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);

    //assert
    expect(() async => await enrollStudent(request), throwsA(isA<InvalidAge>()));
  });
}
