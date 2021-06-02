import 'package:eskola/level.dart';

class Module {
  final Level level;
  final String code;
  final String description;
  final int minimumAge;
  final double price;

  Module({
    required this.level,
    required this.code,
    required this.description,
    required this.minimumAge,
    required this.price,
  });
}
