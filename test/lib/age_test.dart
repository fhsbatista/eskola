import 'package:eskola/age.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('should return age correctly', () {
    //TODO Improve tests because there scenarios that might cause bugs and these tests aren't catching yet.
    final referenceDate = DateTime(2021, 6, 2);
    expect(Age(birthDate: DateTime(2021, 1, 1), referenceDate: referenceDate).value, 0);
    expect(Age(birthDate: DateTime(2020, 1, 1), referenceDate: referenceDate).value, 1);
    expect(Age(birthDate: DateTime(1921, 6, 2), referenceDate: referenceDate).value, 100);
  });
}
