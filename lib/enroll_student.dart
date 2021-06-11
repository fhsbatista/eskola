import 'package:eskola/classroom.dart';
import 'package:eskola/classroom_repository.dart';
import 'package:eskola/enrollment.dart';
import 'package:eskola/enrollment_repository.dart';
import 'package:eskola/failure.dart';
import 'package:eskola/level_repository.dart';
import 'package:eskola/module.dart';
import 'package:eskola/module_repository.dart';
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

  Future<Enrollment> call(EnrollRequest request) async {
    final level = await levelRepository.findByCode(request.level);
    final module = await moduleRepository.findByCode(request.level, request.module);
    final classroom = await classroomRepository.findByCode(
      request.level,
      request.module,
      request.classroom,
    );
    if (classroom.isFinished) throw AlreadyFinishedClass();
    if (classroom.isCompleted25Percent) throw Completed25PercentClass();
    final isCompleted25PercentClassroom = false;
    if (isCompleted25PercentClassroom) throw Completed25PercentClass();
    final isStudentAlreadyEnrolled = await _isStudentAlreadyEnrolled(request.student);
    if (isStudentAlreadyEnrolled) throw StudentAlreadyEnrolled();
    if (!_isValidAge(module, request.student)) throw InvalidAge();
    final hasCapacityOnClassroom = await _hasCapacityOnClassroom(classroom);
    if (!hasCapacityOnClassroom) throw OutOfCapacity();
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    final sequence = await _getNextEnrollmentSequence();
    final code = '$currentYear${level.code}${request.module}${request.classroom}$sequence';
    return Enrollment(
      code: code,
      student: request.student,
      level: level,
      module: module,
      classroom: classroom,
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
}

class EnrollRequest {
  final Student student;
  final String level;
  final String module;
  final String classroom;

  EnrollRequest({
    required this.student,
    required this.level,
    required this.module,
    required this.classroom,
  });
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
