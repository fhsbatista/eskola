import 'package:eskola/level.dart';
import 'package:eskola/module.dart';

class Clazz {
  final Level level;
  final Module module;
  final String code;
  final int capacity;

  Clazz({
    required this.level,
    required this.module,
    required this.code,
    required this.capacity,
  });
}
