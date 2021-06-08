import 'package:eskola/enrollment.dart';
import 'package:eskola/failure.dart';
import 'package:eskola/module.dart';
import 'package:eskola/repository.dart';
import 'package:eskola/student.dart';
import 'package:intl/intl.dart';

class EnrollStudent {
  final Repository repository;

  EnrollStudent({required this.repository});

  Future<String> call(Enrollment enrollment) async {
    final classrooms = await repository.getClassrooms();
    final classroom = classrooms.singleWhere(
      (e) =>
          e.level.code == enrollment.level &&
          e.module.code == enrollment.module &&
          e.code == enrollment.classroom,
    );
    if (classroom.isFinished) throw AlreadyFinishedClass();
    if (classroom.isCompleted25Percent) throw Completed25PercentClass();
    final isCompleted25PercentClassroom = false;
    if (isCompleted25PercentClassroom) throw Completed25PercentClass();
    final isStudentAlreadyEnrolled = await _isStudentAlreadyEnrolled(enrollment.student);
    if (isStudentAlreadyEnrolled) throw StudentAlreadyEnrolled();
    final module = await repository.getModule(enrollment.module);
    if (!_isValidAge(module, enrollment.student)) throw InvalidAge();
    final hasCapacityOnClassroom = await _hasCapacityOnClassroom(enrollment);
    if (!hasCapacityOnClassroom) throw OutOfCapacity();
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    final code = await _getNextCode();
    return '$currentYear${enrollment.level}${enrollment.module}${enrollment.classroom}$code';
  }

  Future<bool> _isStudentAlreadyEnrolled(Student student) async {
    final students = await repository.getStudents();
    final studentsCpf = students.map((e) => e.cpf);
    return studentsCpf.contains(student.cpf);
  }

  bool _isValidAge(Module module, Student student) {
    return student.age.value >= module.minimumAge;
  }

  Future<bool> _hasCapacityOnClassroom(Enrollment request) async {
    final classroom =
        (await repository.getClassrooms()).firstWhere((e) => e.code == request.classroom);
    final studentsOnClassroom = await repository.getClassroomStudents(classroom);
    return studentsOnClassroom.length < classroom.capacity;
  }

  Future<int> _getNextCode() async {
    final lastEnrolledStudentCode = await repository.getLastEnrolledStudentCode();
    return lastEnrolledStudentCode + 1;
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
