class PhoneValidator {
  /// Exact lengths by prefix:
  /// - starts with 0   -> exactly 10 digits (05xxxxxxxx)
  /// - starts with 966 -> exactly 12 digits (9665xxxxxxxx), +966 also accepted
  /// - starts with 5   -> exactly 9 digits (5xxxxxxxx)
  static final _pattern = RegExp(r'^(05\d{8}|5\d{8}|9665\d{8}|\+9665\d{8})$');

  static String normalize(String input) =>
      input.replaceAll(RegExp(r'[\s\-]'), '');

  static bool isValid(String input) => _pattern.hasMatch(normalize(input));

  /// The form sent to the API: bare 9-digit numbers (5xxxxxxxx) gain the
  /// leading zero; the other accepted forms pass through unchanged.
  static String toApiFormat(String input) {
    final normalized = normalize(input);
    return RegExp(r'^5\d{8}$').hasMatch(normalized)
        ? '0$normalized'
        : normalized;
  }
}
