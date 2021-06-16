import 'package:eskola/classroom.dart';
import 'package:eskola/classroom_repository.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/date.dart';
import 'package:eskola/enroll_student.dart';
import 'package:eskola/enrollment.dart';
import 'package:eskola/enrollment_repository.dart';
import 'package:eskola/enrollment_request_dto.dart';
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

  test('should generate code for the enrolled student', () async {
    //arrange
    final level = Level(code: 'EM', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 100,
      installments: 12,
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
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: Date('08/11/1995'),
    );
    final request = EnrollmentRequestDTO(
      studentName: student.name.value,
      studentCpf: student.cpf.value,
      studentBirthDate: '08/11/1995',
      levelCode: level.code,
      moduleCode: module.code,
      classroomCode: classroom.code,
    );
    final enrolledStudentsNumber = 12;
    when(() => enrollmentRepository.count()).thenAnswer((_) async => enrolledStudentsNumber);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);
    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom)).thenAnswer(
      (_) async {
        return [
          Student(
            name: Name('Fernando Batista'),
            cpf: Cpf('383.916.398-60'),
            birthDate: Date('08/11/2020'),
          )
        ];
      },
    );

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
      installments: 12,
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
      birthDate: Date('08/11/2020'),
    );
    final request = EnrollmentRequestDTO(
      studentName: student.name.value,
      studentCpf: student.cpf.value,
      studentBirthDate: '08/11/2020',
      levelCode: level.code,
      moduleCode: module.code,
      classroomCode: classroom.code,
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
      installments: 12,
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
      birthDate: Date('08/11/1995'),
    );
    final request = EnrollmentRequestDTO(
      studentName: student.name.value,
      studentCpf: student.cpf.value,
      studentBirthDate: '08/11/1995',
      levelCode: level.code,
      moduleCode: module.code,
      classroomCode: classroom.code,
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
      installments: 12,
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
      birthDate: Date('08/11/1995'),
    );
    final request = EnrollmentRequestDTO(
      studentName: student.name.value,
      studentCpf: student.cpf.value,
      studentBirthDate: '08/11/1995',
      levelCode: level.code,
      moduleCode: module.code,
      classroomCode: classroom.code,
    );
    final enrollment = Enrollment(
      code: '123',
      student: student,
      level: level,
      module: module,
      classroom: classroom,
      invoices: [],
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
      installments: 12,
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
      birthDate: Date('08/11/1995'),
    );
    final request = EnrollmentRequestDTO(
      studentName: student.name.value,
      studentCpf: student.cpf.value,
      studentBirthDate: '08/11/1995',
      levelCode: level.code,
      moduleCode: module.code,
      classroomCode: classroom.code,
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
      installments: 12,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: '1',
      capacity: 1,
      startDate: DateTime(2021, 5, 18),
      endDate: DateTime(2021, 8, 12),
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: Date('08/11/1995'),
    );
    final request = EnrollmentRequestDTO(
      studentName: student.name.value,
      studentCpf: student.cpf.value,
      studentBirthDate: '08/11/1995',
      levelCode: level.code,
      moduleCode: module.code,
      classroomCode: classroom.code,
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

  test(
      'should generate the invoices based on the number of installments, rounding each amount and applying the rest in the last invoice',
      () async {
    //arrange
    final level = Level(code: 'EF', description: 'Ensino Fundamental');
    final module = Module(
      level: level,
      code: '1',
      description: '1º ano',
      minimumAge: 5,
      price: 1000,
      installments: 12,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: '1',
      capacity: 1,
      startDate: DateTime(2021, 5, 18),
      endDate: DateTime(2022, 7, 12),
    );
    final student = Student(
      name: Name('Fernando Batista'),
      cpf: Cpf('383.916.398-60'),
      birthDate: Date('08/11/1995'),
    );
    final request = EnrollmentRequestDTO(
      studentName: student.name.value,
      studentCpf: student.cpf.value,
      studentBirthDate: '08/11/1995',
      levelCode: level.code,
      moduleCode: module.code,
      classroomCode: classroom.code,
    );
    when(() => enrollmentRepository.count()).thenAnswer((_) async => 12);
    when(() => levelRepository.findByCode(level.code)).thenAnswer((_) async => level);
    when(() => moduleRepository.findByCode(level.code, module.code))
        .thenAnswer((_) async => module);
    when(() => classroomRepository.findByCode(level.code, module.code, classroom.code))
        .thenAnswer((_) async => classroom);
    when(() => enrollmentRepository.getStudentsByClassroom(classroom)).thenAnswer((_) async => []);

    //act
    final enrollment = await enrollStudent(request);

    //assert
    expect(enrollment.invoices.last, 83.37);
    var sumOfInvoices = 0.0;
    enrollment.invoices.forEach((element) => sumOfInvoices += element);
    sumOfInvoices = double.parse(sumOfInvoices.toStringAsFixed(2));
    expect(sumOfInvoices, 1000);
  });
}
