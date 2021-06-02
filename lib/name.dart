class InvalidName implements Exception {
  final String msg;

  InvalidName(this.msg);

  @override
  String toString() {
    return msg;
  }
}

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
