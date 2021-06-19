import 'package:eskola/classroom.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/date.dart';
import 'package:eskola/enrollment.dart';
import 'package:eskola/enrollment_repository.dart';
import 'package:eskola/get_enrollment_usecase.dart';
import 'package:eskola/invoice.dart';
import 'package:eskola/level.dart';
import 'package:eskola/module.dart';
import 'package:eskola/name.dart';
import 'package:eskola/student.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class MockEnrollmentRepository extends Mock implements EnrollmentRepository {}

void main() {
  late MockEnrollmentRepository enrollmentRepository;
  late GetEnrollmentUsecase getEnrollmentUsecase;

  setUpAll(() {
    enrollmentRepository = MockEnrollmentRepository();
    getEnrollmentUsecase = GetEnrollmentUsecase(enrollmentRepository);
  });

  test('should get enrollment with balance', () async {
    //arrange
    final enrollmentCode = '2021EM1A0001';
    final level = Level(code: 'EM', description: 'Ensino Médio');
    final module = Module(
      level: level,
      code: '1A',
      description: '1A',
      minimumAge: 15,
      price: 1000,
      installments: 12,
    );
    final classroom = Classroom(
      level: level,
      module: module,
      code: '123',
      capacity: 20,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 365)),
    );
    final enrollmentBalance = 166.7;
    when(() => enrollmentRepository.findByCode(enrollmentCode)).thenAnswer(
      (_) async => Enrollment(
        code: enrollmentCode,
        level: level,
        module: module,
        classroom: classroom,
        student: Student(
          name: Name('Fernando Batista'),
          cpf: Cpf('791.677.770-31'),
          birthDate: Date('08/11/1995'),
        ),
        invoices: [
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: true),
          Invoice(amount: 83.33, isPaid: false),
          Invoice(amount: 83.37, isPaid: false)
        ],
      ),
    );

    //act
    final enrollment = await getEnrollmentUsecase(enrollmentCode);

    //assert
    expect(enrollment.code, enrollmentCode);
    expect(enrollment.balance, enrollmentBalance);
  });
}
