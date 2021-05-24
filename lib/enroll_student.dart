import 'package:eskola/cpf_validator.dart';
import 'package:eskola/errors.dart';

class Student {
  final String name;
  final String cpf;

  Student({
    required this.name,
    required this.cpf,
  });
}

class EnrollRequest {
  final Student student;

  EnrollRequest({required this.student});
}

class EnrollStudent {
  final CpfValidator cpfValidator;

  EnrollStudent({required this.cpfValidator});

  String call(EnrollRequest request) {
    if (isInvalidName(request.student.name)) throw InvalidName();
    if (isInvalidCpf(request.student.cpf)) throw InvalidCpf();
    final id = 'fea65';
    return id;
  }

  bool isInvalidName(String name) {
    final exp = RegExp(r'^([A-Za-z]+ )+([A-Za-z])+$');
    return !exp.hasMatch(name);
  }

  bool isInvalidCpf(String cpf) {
    return !cpfValidator.isValid(cpf);
  }
}
