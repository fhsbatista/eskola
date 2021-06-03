import 'package:eskola/failure.dart';

class Name {
  final String value;

  Name(this.value) {
    if (!isValid(value)) throw InvalidName('The name is invalid');
  }

  static bool isValid(String name) {
    final exp = RegExp(r'^([A-Za-z]+ )+([A-Za-z])+$');
    return exp.hasMatch(name);
  }
}

class InvalidName extends Failure {
  InvalidName(String msg) : super(msg);
}
