import 'package:eskola/classroom.dart';
import 'package:eskola/enrollment.dart';
import 'package:eskola/student.dart';

abstract class EnrollmentRepository {
  //TODO change entity for a dto instead
  Future<Enrollment?> findByCode(String code);
  Future<Enrollment?> findByCpf(String cpf);
  Future<List<Student>> getStudentsByClassroom(Classroom classroom);
  Future<int> count();
}
