import 'package:eskola/failure.dart';

class Code {
  final String value;

  Code(int value) : value = value.toString() {
    if (!isValid(value)) {
      throw InvalidCode('The code is invalid. It should be greater than 0 and less then 9999');
    }
  }

  bool isValid(int code) {
    return code > 0 && code <= 9999;
  }
}

class InvalidCode extends Failure {
  InvalidCode(String msg) : super(msg);
}
