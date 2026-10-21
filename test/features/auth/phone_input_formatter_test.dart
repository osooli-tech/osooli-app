import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/features/auth/presentation/widgets/phone_input_formatter.dart';

TextEditingValue _apply(String oldText, String newText) =>
    PhoneInputFormatter().formatEditUpdate(
      TextEditingValue(text: oldText),
      TextEditingValue(text: newText),
    );

void main() {
  test('caps 05-numbers at 10 digits', () {
    expect(_apply('0511111111', '05111111112').text, '0511111111');
    expect(_apply('051111111', '0511111111').text, '0511111111');
  });

  test('caps bare 5-numbers at 9 digits', () {
    expect(_apply('511111111', '5111111111').text, '511111111');
    expect(_apply('51111111', '511111111').text, '511111111');
  });

  test('caps 966-numbers at 12 digits', () {
    expect(_apply('966511111111', '9665111111112').text, '966511111111');
    expect(_apply('+966511111111', '+9665111111112').text, '+966511111111');
  });

  test('separators do not count toward the cap', () {
    expect(_apply('05 1111 111', '05 1111 1111').text, '05 1111 1111');
  });
}
