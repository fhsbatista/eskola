import 'package:intl/intl.dart';

class Date {
  final DateTime value;

  Date(String date) : value = DateFormat('dd/MM/yyyy').parse(date);
}
