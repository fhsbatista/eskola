import 'package:eskola/clazz.dart';
import 'package:eskola/level.dart';
import 'package:eskola/local_datasource.dart';
import 'package:eskola/module.dart';

abstract class Repository {
  Future<int> getLastEnrolledStudentCode();
  Future<List<Level>> getLevels();
  Future<List<Module>> getModules();
  Future<Module> getModule(String code);
  Future<List<Clazz>> getClazzes();
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
}
