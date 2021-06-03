import 'package:eskola/age.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/failure.dart';
import 'package:eskola/module.dart';
import 'package:eskola/name.dart';
import 'package:eskola/repository.dart';
import 'package:intl/intl.dart';

class Student {
  final Name name;
  final Cpf cpf;
  final DateTime birthDate;

  Student({
    required this.name,
    required this.cpf,
    required this.birthDate,
  });
}

class EnrollRequest {
  final Student student;
  final String level;
  final String module;
  final String clazz;

  EnrollRequest({
    required this.student,
    required this.level,
    required this.module,
    required this.clazz,
  });
}

class EnrollStudent {
  final Repository repository;

  EnrollStudent({required this.repository});

  Future<String> call(EnrollRequest request) async {
    final isStudentAlreadyEnrolled = await _isStudentAlreadyEnrolled(request.student);
    if (isStudentAlreadyEnrolled) throw StudentAlreadyEnrolled();
    final module = await repository.getModule(request.module);
    if (!_isValidAge(module, request.student)) throw InvalidAge();
    final hasCapacityOnClazz = await _hasCapacityOnClazz(request);
    if (!hasCapacityOnClazz) throw OutOfCapacity();
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    final code = await _getNextCode();
    return '$currentYear${request.level}${request.module}${request.clazz}$code';
  }

  Future<bool> _isStudentAlreadyEnrolled(Student student) async {
    final students = await repository.getStudents();
    final studentsCpf = students.map((e) => e.cpf);
    return studentsCpf.contains(student.cpf);
  }

  bool _isValidAge(Module module, Student student) {
    final age = Age(birthDate: student.birthDate);
    return age.value >= module.minimumAge;
  }

  Future<bool> _hasCapacityOnClazz(EnrollRequest request) async {
    final clazz = (await repository.getClazzes()).firstWhere((e) => e.code == request.clazz);
    final studentsOnClazz = await repository.getClazzStudents(clazz);
    return studentsOnClazz.length < clazz.capacity;
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
  OutOfCapacity() : super('Clazz has no capacity for more students');
}

class StudentAlreadyEnrolled extends Failure {
  StudentAlreadyEnrolled() : super('Attempt to enroll a duplicated student');
}
