import 'package:eskola/level.dart';
import 'package:eskola/module.dart';

class Classroom {
  final Level level;
  final Module module;
  final String code;
  final int capacity;
  final DateTime startDate;
  final DateTime endDate;

  bool get isFinished => endDate.isBefore(DateTime.now());

  bool get isCompleted25Percent {
    final daysOnClass = endDate.difference(startDate).inDays;
    final completedDays = DateTime.now().difference(startDate).inDays;
    final completedPercentage = completedDays / daysOnClass;
    return completedPercentage > 0.25;
  }

  Classroom({
    required this.level,
    required this.module,
    required this.code,
    required this.capacity,
    required this.startDate,
    required this.endDate,
  });
}
