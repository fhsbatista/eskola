import 'package:eskola/age.dart';
import 'package:eskola/cpf.dart';
import 'package:eskola/date.dart';
import 'package:eskola/name.dart';

class Student {
  final Name name;
  final Cpf cpf;
  final Date birthDate;

  Age get age => Age(birthDate: birthDate);

  Student({
    required this.name,
    required this.cpf,
    required this.birthDate,
  });
}
