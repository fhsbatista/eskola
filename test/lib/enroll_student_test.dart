import 'package:eskola/classroom.dart';
import 'package:eskola/classroom_repository.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/enroll_student.dart';
import 'package:eskola/enrollment.dart';
import 'package:eskola/enrollment_repository.dart';
import 'package:eskola/level.dart';
import 'package:eskola/level_repository.dart';
import 'package:eskola/module.dart';
import 'package:eskola/module_repository.dart';
import 'package:eskola/name.dart';
import 'package:eskola/student.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class MockLevelRepository extends Mock implements LevelRepository {}

class MockModuleRepository extends Mock implements ModuleRepository {}

class MockClassroomRepository extends Mock implements ClassroomRepository {}

class MockEnrollmentRepository extends Mock implements EnrollmentRepository {}

void main() {
  late MockLevelRepository levelRepository;
  late MockModuleRepository moduleRepository;
  late MockClassroomRepository classroomRepository;
  late MockEnrollmentRepository enrollmentRepository;
  late EnrollStudent enrollStudent;
  //todo inverter dependencia da data, do contrário os testes ficam inviáveis
  //todo refaturar o usecase para tirar coisas fora de responsabilidae (ex: codigo da matricula e idade minima)
  setUpAll(() {
    levelRepository = MockLevelRepository();
    moduleRepository = MockModuleRepository();
    classroomRepository = MockClassroomRepository();
    enrollmentRepository = MockEnrollmentRepository();
    enrollStudent = EnrollStudent(
      levelRepository: levelRepository,
      moduleRepository: moduleRepository,
      classroomRepository: classroomRepository,
      enrollmentRepository: enrollmentRepository,
    );
    when(() => enrollmentRepository.findByCpf(any())).thenAnswer((_) async => null);
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
    final request = EnrollRequest(
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
    final enrolledStudentsNumber = 12;
    when(() => enrollmentRepository.count()).thenAnswer((_) async => enrolledStudentsNumber);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);
    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom))
        .thenAnswer((_) async => [student]);

    //act
    final enrollment = await enrollStudent(request);

    //assert
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    expect(
      enrollment.code,
      '$currentYear${level.code}${module.code}${classroom.code}${enrolledStudentsNumber + 1}',
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
    final request = EnrollRequest(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => enrollmentRepository.count()).thenAnswer((_) async => 1);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);

    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom))
        .thenAnswer((_) async => [student]);

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
    final request = EnrollRequest(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => enrollmentRepository.count()).thenAnswer((_) async => 1);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);

    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom))
        .thenAnswer((_) async => [student]);

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
    final request = EnrollRequest(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    final enrollment = Enrollment(
      code: '123',
      student: student,
      level: level,
      module: module,
      classroom: classroom,
    );
    when(() => enrollmentRepository.count()).thenAnswer((_) async => 1);
    when(() => enrollmentRepository.findByCpf(student.cpf.value))
        .thenAnswer((_) async => enrollment);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);

    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom))
        .thenAnswer((_) async => [student]);

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
    final request = EnrollRequest(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => enrollmentRepository.count()).thenAnswer((_) async => 1);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);

    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);

    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom))
        .thenAnswer((_) async => [student]);

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
    final request = EnrollRequest(
      student: student,
      level: level.code,
      module: module.code,
      classroom: classroom.code,
    );
    when(() => enrollmentRepository.count()).thenAnswer((_) async => 1);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);

    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom))
        .thenAnswer((_) async => [student]);

    //assert
    expect(() async => await enrollStudent(request), throwsA(isA<Completed25PercentClass>()));
  });

//  test(
//      'should generate the invoices based on the number of installments, rounding each amount and applying the rest in the last invoice',
//      () async {
//    //arrange
//    final level = Level(code: 'EF', description: 'Ensino Fundamental');
//    final module = Module(
//      level: level,
//      code: '1',
//      description: '1º ano',
//      minimumAge: 5,
//      price: 1000,
//    );
//    final classroom = Classroom(
//      level: level,
//      module: module,
//      code: '1',
//      capacity: 1,
//      startDate: DateTime(2021, 5, 18),
//      endDate: DateTime(2021, 6, 12),
//    );
//    final student = Student(
//      name: Name('Fernando Batista'),
//      cpf: Cpf('383.916.398-60'),
//      birthDate: DateTime(1995, 11, 8),
//    );
//    final request = Enrollment(
//      student: student,
//      level: level.code,
//      module: module.code,
//      classroom: classroom.code,
//    );
//    when(() => repository.getStudents()).thenAnswer((_) async => [student]);
//    when(() => repository.getLastEnrolledStudentCode()).thenAnswer((_) async => 1);
//    when(() => repository.getModule(module.code)).thenAnswer((_) async => module);
//    when(() => repository.getClassrooms()).thenAnswer((_) async => [classroom]);
//    when(() => repository.getClassroomStudents(classroom)).thenAnswer((_) async => [student]);
//
//    //act
//    final enrollmentCode = await enrollStudent(request);
//
//    //assert
//    //como testar os invoices? ver na aula gravada
////    verify(() => repository.)
////    expect(invoices.last, 83.37);
////    final sumOfInvoices = invoices.fold(0, (previous, current) => previous ?? 0 + current);
////    expect(sumOfInvoices, 1000);
//  });
}
