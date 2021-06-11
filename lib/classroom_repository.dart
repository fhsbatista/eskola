import 'classroom.dart';

abstract class ClassroomRepository {
  Future<Classroom> findByCode(String levelCode, String moduleCode, String classroomCode);
}
