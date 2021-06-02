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

class InvalidCode implements Exception {
  final String msg;

  InvalidCode(this.msg);

  @override
  String toString() {
    return msg;
  }
}
