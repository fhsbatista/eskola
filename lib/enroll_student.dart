import 'package:eskola/classroom.dart';
import 'package:eskola/classroom_repository.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/date.dart';
import 'package:eskola/enrollment.dart';
import 'package:eskola/enrollment_repository.dart';
import 'package:eskola/enrollment_request_dto.dart';
import 'package:eskola/failure.dart';
import 'package:eskola/level_repository.dart';
import 'package:eskola/module.dart';
import 'package:eskola/module_repository.dart';
import 'package:eskola/name.dart';
import 'package:eskola/student.dart';
import 'package:intl/intl.dart';

class EnrollStudent {
  final LevelRepository levelRepository;
  final ModuleRepository moduleRepository;
  final ClassroomRepository classroomRepository;
  final EnrollmentRepository enrollmentRepository;

  EnrollStudent({
    required this.levelRepository,
    required this.moduleRepository,
    required this.classroomRepository,
    required this.enrollmentRepository,
  });

  Future<Enrollment> call(EnrollmentRequestDTO request) async {
    final level = await levelRepository.findByCode(request.levelCode);
    final module = await moduleRepository.findByCode(request.levelCode, request.moduleCode);
    final classroom = await classroomRepository.findByCode(
      request.levelCode,
      request.moduleCode,
      request.classroomCode,
    );
    final student = Student(
      name: Name(request.studentName),
      cpf: Cpf(request.studentCpf),
      birthDate: Date(request.studentBirthDate),
    );
    if (classroom.isFinished) throw AlreadyFinishedClass();
    if (classroom.isCompleted25Percent) throw Completed25PercentClass();
    final isCompleted25PercentClassroom = false;
    if (isCompleted25PercentClassroom) throw Completed25PercentClass();
    final isStudentAlreadyEnrolled = await _isStudentAlreadyEnrolled(student);
    if (isStudentAlreadyEnrolled) throw StudentAlreadyEnrolled();
    if (!_isValidAge(module, student)) throw InvalidAge();
    final hasCapacityOnClassroom = await _hasCapacityOnClassroom(classroom);
    if (!hasCapacityOnClassroom) throw OutOfCapacity();
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    final sequence = await _getNextEnrollmentSequence();
    final code = '$currentYear${level.code}${module.code}${classroom.code}$sequence';
    final invoices = _getInvoices(module);
    return Enrollment(
      code: code,
      student: student,
      level: level,
      module: module,
      classroom: classroom,
      invoices: invoices,
    );
  }

  Future<bool> _isStudentAlreadyEnrolled(Student student) async {
    final enrollment = await enrollmentRepository.findByCpf(student.cpf.value);
    return enrollment != null;
  }

  bool _isValidAge(Module module, Student student) {
    return student.age.value >= module.minimumAge;
  }

  Future<bool> _hasCapacityOnClassroom(Classroom classroom) async {
    final studentsOnClassroom = await enrollmentRepository.getStudentsByClassroom(classroom);
    return studentsOnClassroom.length < classroom.capacity;
  }

  Future<int> _getNextEnrollmentSequence() async {
    final lastEnrolledStudentCode = await enrollmentRepository.count();
    return lastEnrolledStudentCode + 1;
  }

  //TODO This method is a bit hard to understand. Refactor it later. (this method should be in enrollment entity actually)
  List<double> _getInvoices(Module module) {
    final installmentFloorValue =
        double.parse((module.price / module.installments).toStringAsFixed(2));
    final lastInstallmentValue = double.parse(
        (module.price - (installmentFloorValue * (module.installments - 1))).toStringAsFixed(2));
    final invoices = <double>[];
    for (var i = 1; i <= module.installments; i++) {
      if (i == module.installments) {
        invoices.add(lastInstallmentValue);
      } else {
        invoices.add(installmentFloorValue);
      }
    }
    return invoices;
  }
}

class InvalidAge extends Failure {
  InvalidAge() : super('Student age is less than minimum age');
}

class OutOfCapacity extends Failure {
  OutOfCapacity() : super('Classroom has no capacity for more students');
}

class StudentAlreadyEnrolled extends Failure {
  StudentAlreadyEnrolled() : super('Attempt to enroll a duplicated student');
}

class AlreadyFinishedClass extends Failure {
  AlreadyFinishedClass() : super('This class is already finished');
}

class Completed25PercentClass extends Failure {
  Completed25PercentClass() : super('This class is 25% completed already');
}
