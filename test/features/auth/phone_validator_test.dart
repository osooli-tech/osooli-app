import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/auth/domain/validators/phone_validator.dart';

void main() {
  test('accepts the three server formats', () {
    expect(PhoneValidator.isValid('0511111111'), isTrue);
    expect(PhoneValidator.isValid('9665111111 11'), isTrue);
    expect(PhoneValidator.isValid('+9665-1111-1111'), isTrue);
  });

  test('rejects wrong formats', () {
    expect(PhoneValidator.isValid('051111111'), isFalse); // 9 digits
    expect(PhoneValidator.isValid('0611111111'), isFalse); // not 05
    expect(PhoneValidator.isValid('abc'), isFalse);
    expect(PhoneValidator.isValid(''), isFalse);
  });

  test('normalize strips separators', () {
    expect(PhoneValidator.normalize('+966 51 111-1111'), '+966511111111');
  });
}
