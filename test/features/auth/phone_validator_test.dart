import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/features/auth/domain/validators/phone_validator.dart';

void main() {
  test('accepts exact lengths per prefix', () {
    expect(PhoneValidator.isValid('0511111111'), isTrue); // 0 -> 10 digits
    expect(PhoneValidator.isValid('511111111'), isTrue); // 5 -> 9 digits
    expect(PhoneValidator.isValid('966511111111'), isTrue); // 966 -> 12
    expect(PhoneValidator.isValid('+966 51 111-1111'), isTrue);
  });

  test('rejects wrong lengths and prefixes', () {
    expect(PhoneValidator.isValid('051111111'), isFalse); // 0 with 9 digits
    expect(PhoneValidator.isValid('05111111111'), isFalse); // 0 with 11
    expect(PhoneValidator.isValid('51111111'), isFalse); // 5 with 8
    expect(PhoneValidator.isValid('5111111111'), isFalse); // 5 with 10
    expect(PhoneValidator.isValid('96651111111'), isFalse); // 966 with 11
    expect(PhoneValidator.isValid('9665111111111'), isFalse); // 966 with 13
    expect(PhoneValidator.isValid('0611111111'), isFalse); // not a mobile
    expect(PhoneValidator.isValid('abc'), isFalse);
    expect(PhoneValidator.isValid(''), isFalse);
  });

  test('normalize strips separators', () {
    expect(PhoneValidator.normalize('+966 51 111-1111'), '+966511111111');
  });

  test('toApiFormat adds leading zero to bare 9-digit numbers only', () {
    expect(PhoneValidator.toApiFormat('511111111'), '0511111111');
    expect(PhoneValidator.toApiFormat('0511111111'), '0511111111');
    expect(PhoneValidator.toApiFormat('966511111111'), '966511111111');
    expect(PhoneValidator.toApiFormat('+966511111111'), '+966511111111');
  });
}
