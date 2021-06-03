class Failure implements Exception {
  final String msg;

  Failure(this.msg);

  @override
  String toString() {
    return msg;
  }
}
