import 'package:eskola/classroom.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/enroll_student.dart';
import 'package:eskola/enrollment.dart';
import 'package:eskola/level.dart';
import 'package:eskola/module.dart';
import 'package:eskola/name.dart';
import 'package:eskola/repository.dart';
import 'package:eskola/student.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository repository;
  late EnrollStudent enrollStudent;
  //todo inverter dependencia da data, do contrário os testes ficam inviáveis
  //todo refaturar o usecase para tirar coisas fora de responsabilidae (ex: codigo da matricula e idade minima)
  //todo refatorar completed25 para get progress
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
    final level = Level(code: 'EM', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 100,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: 'A',
      capacity: 10,
      startDate: DateTime(
        2021,
        05,
        01,
      ),
      endDate: DateTime(
        2025,
        01,
        01,
      ),
    );
    final request = Enrollment(
      student: validStudent,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: DateTime(2020, 11, 8),
    );
    final lastEnrolledStudentCode = 12;
    when(() => repository.getStudents()).thenAnswer((_) async => [student]);
    when(() => repository.getLastEnrolledStudentCode())
        .thenAnswer((_) async => lastEnrolledStudentCode);
    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);
    when(() => repository.getClassrooms()).thenAnswer((_) async => [classroom]);
    when(() => repository.getClassroomStudents(classroom)).thenAnswer((_) async => [student]);

    //act
    final result = await enrollStudent(request);

    //assert
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    expect(
      result,
      '$currentYear${level.code}${module.code}${classroom.code}${lastEnrolledStudentCode + 1}',
    );
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
    final classroom = Classroom(
      level: level,
      module: module,
      code: '1',
      capacity: 20,
      startDate: DateTime(
        2020,
        01,
        01,
      ),
      endDate: DateTime(
        2030,
        01,
        01,
      ),
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: DateTime(2020, 11, 8),
    );
    final request = Enrollment(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => repository.getLastEnrolledStudentCode()).thenAnswer((_) async => 1);
    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);
    when(() => repository.getClassrooms()).thenAnswer((_) async => [classroom]);
    when(() => repository.getClassroomStudents(classroom)).thenAnswer((_) async => [student]);
    when(() => repository.getStudents()).thenAnswer((_) async => []);

    //assert
    expect(() async => await enrollStudent(request), throwsA(isA<InvalidAge>()));
  });

  test('should throw OutOfCapacity when trying to enroll over class capacity', () {
    //arrange
    final level = Level(code: 'EF', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 100,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: '1',
      capacity: 1,
      startDate: DateTime(
        2020,
        01,
        01,
      ),
      endDate: DateTime(
        2026,
        01,
        01,
      ),
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: DateTime(1995, 11, 8),
    );
    final request = Enrollment(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => repository.getLastEnrolledStudentCode()).thenAnswer((_) async => 1);
    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);
    when(() => repository.getClassrooms()).thenAnswer((_) async => [classroom]);
    when(() => repository.getClassroomStudents(classroom)).thenAnswer((_) async => [student]);

    //assert
    expect(() async => await enrollStudent(request), throwsA(isA<OutOfCapacity>()));
  });
  test('should throw StudentAlreadyEnrolled when trying to enroll a duplicated student', () {
    //arrange
    final level = Level(code: 'EF', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 100,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: '1',
      capacity: 1,
      startDate: DateTime(
        2020,
        01,
        01,
      ),
      endDate: DateTime(
        2026,
        01,
        01,
      ),
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: DateTime(1995, 11, 8),
    );
    final request = Enrollment(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => repository.getStudents()).thenAnswer((_) async => [student]);
    when(() => repository.getLastEnrolledStudentCode()).thenAnswer((_) async => 1);
    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);
    when(() => repository.getClassrooms()).thenAnswer((_) async => [classroom]);
    when(() => repository.getClassroomStudents(classroom)).thenAnswer((_) async => [student]);

    //assert
    expect(() async => await enrollStudent(request), throwsA(isA<StudentAlreadyEnrolled>()));
  });
  test(
      'should throw AlreadyFinishedClass when trying to enroll a student on a class that is already finished',
      () {
    //arrange
    final level = Level(code: 'EF', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 100,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: '1',
      capacity: 10,
      startDate: DateTime(2020, 1, 1),
      endDate: DateTime(2021, 1, 1),
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: DateTime(1995, 11, 8),
    );
    final request = Enrollment(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => repository.getStudents()).thenAnswer((_) async => []);
    when(() => repository.getLastEnrolledStudentCode()).thenAnswer((_) async => 1);
    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);
    when(() => repository.getClassrooms()).thenAnswer((_) async => [classroom]);
    when(() => repository.getClassroomStudents(classroom)).thenAnswer((_) async => [student]);

    //assert
    expect(() async => await enrollStudent(request), throwsA(isA<AlreadyFinishedClass>()));
  });

  test(
      'should throw Completed25PercentClass when trying to enroll a student on a class that is 25% complete',
      () {
    //arrange
    final level = Level(code: 'EF', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 100,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: '1',
      capacity: 1,
      startDate: DateTime(2021, 5, 18),
      endDate: DateTime(2021, 6, 12),
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: DateTime(1995, 11, 8),
    );
    final request = Enrollment(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => repository.getStudents()).thenAnswer((_) async => [student]);
    when(() => repository.getLastEnrolledStudentCode()).thenAnswer((_) async => 1);
    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);
    when(() => repository.getClassrooms()).thenAnswer((_) async => [classroom]);
    when(() => repository.getClassroomStudents(classroom)).thenAnswer((_) async => [student]);

    //assert
    expect(() async => await enrollStudent(request), throwsA(isA<Completed25PercentClass>()));
  });
}
