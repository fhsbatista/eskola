//fazer retornar level, modules e classes;
import 'package:eskola/clazz.dart';
import 'package:eskola/enroll_student.dart';
import 'package:eskola/level.dart';
import 'package:eskola/module.dart';
import 'package:eskola/student.dart';

abstract class LocalDatasource {
  Future<int> getLastEnrolledStudentCode();

  Future<List<Level>> getLevels();

  Future<List<Module>> getModules();

  Future<Module> getModule(String code);

  Future<List<Clazz>> getClazzes();

  Future<List<Student>> getClazzStudents(Clazz clazz);

  Future<List<Student>> getStudents();

  Future<Null> enroll(EnrollRequest enrollment);
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

  //todo criar entidade "enrollment"
  static final enrollments = <EnrollRequest>[];

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

  @override
  Future<List<Student>> getClazzStudents(Clazz clazz) {
    return Future.value(
      enrollments.where((e) => e.clazz == clazz.code).map((e) => e.student).toList(),
    );
  }

  @override
  Future<Null> enroll(EnrollRequest enrollment) {
    enrollments.add(enrollment);
    return Future.value(null);
  }

  @override
  Future<List<Student>> getStudents() {
    final students = enrollments.map((e) => e.student).toList();
    return Future.value(students);
  }
}
