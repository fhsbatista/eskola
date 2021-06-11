import 'package:eskola/module.dart';

abstract class ModuleRepository {
  Future<Module> findByCode(String levelCode, String moduleCode);
}
