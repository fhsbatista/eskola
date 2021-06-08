import 'package:eskola/student.dart';

class Enrollment {
  final Student student;
  final String level;
  final String module;
  final String classroom;

  Enrollment({
    required this.student,
    required this.level,
    required this.module,
    required this.classroom,
  });
}
