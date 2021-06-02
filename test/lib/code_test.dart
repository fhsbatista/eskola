import 'package:eskola/code.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('should instantiate code with no problems', () {
    expect(Code(1), isA<Code>());
    expect(Code(123), isA<Code>());
    expect(Code(1234), isA<Code>());
    expect(Code(9999), isA<Code>());
  });

  test('should throw InvalidCode', () {
    expect(() => Code(0), throwsA(isA<InvalidCode>()));
    expect(() => Code(10000), throwsA(isA<InvalidCode>()));
    expect(() => Code(99999), throwsA(isA<InvalidCode>()));
  });
}
