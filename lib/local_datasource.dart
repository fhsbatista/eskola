//fazer retornar level, modules e classes;
import 'package:eskola/clazz.dart';
import 'package:eskola/level.dart';
import 'package:eskola/module.dart';

abstract class LocalDatasource {
  Future<int> getLastEnrolledStudentCode();

  Future<List<Level>> getLevels();

  Future<List<Module>> getModules();

  Future<Module> getModule(String code);

  Future<List<Clazz>> getClazzes();
}

class LocalDatasourceImpl implements LocalDatasource {
  static final levels = [
    Level(code: 'EF', description: 'Ensino Fundamental'),
    Level(code: 'EM', description: 'Ensino Médio'),
    Level(code: 'TE', description: 'Técnico em Enfermagem'),
  ];

  static final modules = [
    Module(level: levels[0], code: '1', description: '1º Ano', minimumAge: 5, price: 100),
    Module(level: levels[1], code: '1', description: '1º Ano', minimumAge: 14, price: 200),
    Module(level: levels[2], code: '1', description: '1º Ano', minimumAge: 16, price: 300),
  ];

  static final clazzes = [
    Clazz(level: modules[0].level, module: modules[0], code: '1', capacity: 30),
    Clazz(level: modules[1].level, module: modules[1], code: '1', capacity: 30),
    Clazz(level: modules[2].level, module: modules[2], code: '1', capacity: 30),
  ];

  @override
  Future<List<Level>> getLevels() {
    return Future.value(levels);
  }

  @override
  Future<List<Module>> getModules() {
    return Future.value(modules);
  }

  @override
  Future<Module> getModule(String code) {
    final module = modules.firstWhere((element) => element.code == code);
    return Future.value(module);
  }

  @override
  Future<List<Clazz>> getClazzes() {
    return Future.value(clazzes);
  }

  @override
  Future<int> getLastEnrolledStudentCode() {
    return Future.value(12);
  }
}
