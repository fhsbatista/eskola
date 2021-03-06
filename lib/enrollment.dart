import 'package:eskola/classroom.dart';
import 'package:eskola/invoice.dart';
import 'package:eskola/level.dart';
import 'package:eskola/module.dart';
import 'package:eskola/student.dart';

class Enrollment {
  final String code;
  final Student student;
  final Level level;
  final Module module;
  final Classroom classroom;
  //Todo refactor so that finances handling get event driven (more reliability by that way)
  final List<Invoice> invoices;

  Enrollment({
    required this.code,
    required this.student,
    required this.level,
    required this.module,
    required this.classroom,
    required this.invoices,
  });
}
