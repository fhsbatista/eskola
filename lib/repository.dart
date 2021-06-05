import 'package:eskola/clazz.dart';
import 'package:eskola/level.dart';
import 'package:eskola/local_datasource.dart';
import 'package:eskola/module.dart';
import 'package:eskola/student.dart';

abstract class Repository {
  Future<int> getLastEnrolledStudentCode();
  Future<List<Level>> getLevels();
  Future<List<Module>> getModules();
  Future<Module> getModule(String code);
  Future<List<Clazz>> getClazzes();
  Future<List<Student>> getClazzStudents(Clazz clazz);
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
  Future<List<Clazz>> getClazzes() {
    return localDatasource.getClazzes();
  }

  @override
  Future<int> getLastEnrolledStudentCode() {
    return localDatasource.getLastEnrolledStudentCode();
  }

  @override
  Future<List<Student>> getClazzStudents(Clazz clazz) {
    return localDatasource.getClazzStudents(clazz);
  }

  @override
  Future<List<Student>> getStudents() {
    return localDatasource.getStudents();
  }
}
