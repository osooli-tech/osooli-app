import 'package:flutter/services.dart';

/// Blocks typing beyond the exact digit count each prefix allows:
/// starts with 0 -> 10 digits, bare 5 -> 9 digits, 966/+966 -> 12 digits.
/// Separators (space/dash) and the leading + are not counted.
class PhoneInputFormatter extends TextInputFormatter {
  static int _digitCount(String text) =>
      text.replaceAll(RegExp(r'\D'), '').length;

  static int _maxDigitsFor(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) return 10;
    if (digits.startsWith('5')) return 9;
    // 9 / 96 / 966… — allow the international form to be completed.
    return 12;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_digitCount(newValue.text) > _maxDigitsFor(newValue.text)) {
      return oldValue;
    }
    return newValue;
  }
}
