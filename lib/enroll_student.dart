import 'package:eskola/age.dart';
import 'package:eskola/cpf.dart';
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
    final module = await repository.getModule(request.module);
    if (!_isValidAge(module, request.student)) {
      throw InvalidAge('Student age is less than minimum age');
    }
    final currentYear = DateFormat('yyyy').format(DateTime.now());
    final code = await _getNextCode();
    return '$currentYear${request.level}${request.module}${request.clazz}$code';
  }

  bool _isValidAge(Module module, Student student) {
    final age = Age(birthDate: student.birthDate);
    return age.value >= module.minimumAge;
  }

  Future<int> _getNextCode() async {
    final lastEnrolledStudentCode = await repository.getLastEnrolledStudentCode();
    return lastEnrolledStudentCode + 1;
  }
}

class InvalidAge implements Exception {
  final String msg;

  InvalidAge(this.msg);

  @override
  String toString() {
    return msg;
  }
}
