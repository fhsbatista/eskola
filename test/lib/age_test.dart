import 'package:eskola/age.dart';
import 'package:eskola/date.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('should return age correctly', () {
    //TODO Improve tests because there scenarios that might cause bugs and these tests aren't catching yet.
    final referenceDate = Date('06/02/2021');
    expect(Age(birthDate: Date('01/01/2021'), referenceDate: referenceDate).value, 0);
    expect(Age(birthDate: Date('01/01/2020'), referenceDate: referenceDate).value, 1);
    expect(Age(birthDate: Date('02/06/1921'), referenceDate: referenceDate).value, 100);
  });
}
