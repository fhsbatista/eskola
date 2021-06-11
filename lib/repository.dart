import 'package:eskola/classroom.dart';
import 'package:eskola/level.dart';
import 'package:eskola/local_datasource.dart';
import 'package:eskola/module.dart';
import 'package:eskola/student.dart';

abstract class Repository {
  //criar repositorios para level, modules etc e criar os metodos "findbycode" para arrumar o usecase
  Future<int> getLastEnrolledStudentCode();
  Future<List<Level>> getLevels();
  Future<List<Module>> getModules();
  Future<Module> getModule(String code);
  Future<List<Classroom>> getClassrooms();
  Future<List<Student>> getClassroomStudents(Classroom classroom);
  Future<List<Student>> getStudents();
}

class RepositoryImpl implements Repository {
  final LocalDatasource localDatasource;

  RepositoryImpl({required this.localDatasource});

  @override
  Future<List<Level>> getLevels() {
    return localDatasource.getLevels();
  }

  @override
  Future<List<Module>> getModules() {
    return localDatasource.getModules();
  }

  @override
  Future<Module> getModule(String code) async {
    return await localDatasource.getModule(code);
  }

  @override
  Future<List<Classroom>> getClassrooms() {
    return localDatasource.getClassrooms();
  }

  @override
  Future<int> getLastEnrolledStudentCode() {
    return localDatasource.getLastEnrolledStudentCode();
  }

  @override
  Future<List<Student>> getClassroomStudents(Classroom classroom) {
    return localDatasource.getClassroomsStudents(classroom);
  }

  @override
  Future<List<Student>> getStudents() {
    return localDatasource.getStudents();
  }
}
