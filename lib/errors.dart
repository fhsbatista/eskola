abstract class Error implements Exception {
  final String msg;

  Error(this.msg);
}

abstract class EnrollmentError implements Error {}

class InvalidName implements Error {
  @override
  String get msg => 'The student\'s name is invalid';
}

class InvalidCpf implements Error {
  @override
  String get msg => 'The student\'s cpf is invalid';
}
