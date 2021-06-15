import 'package:eskola/classroom.dart';
import 'package:eskola/level.dart';
import 'package:eskola/module.dart';
import 'package:eskola/student.dart';

class Enrollment {
  final String code;
  final Student student;
  final Level level;
  final Module module;
  final Classroom classroom;
  //proximo passo: gerar os invoices.

  Enrollment({
    required this.code,
    required this.student,
    required this.level,
    required this.module,
    required this.classroom,
  });
}
