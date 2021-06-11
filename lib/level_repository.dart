import 'package:eskola/level.dart';

abstract class LevelRepository {
  Future<Level> findByCode(String code);
}
