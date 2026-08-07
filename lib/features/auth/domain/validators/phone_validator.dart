class PhoneValidator {
  static final _pattern = RegExp(r'^(05\d{8}|9665\d{8}|\+9665\d{8})$');

  static String normalize(String input) =>
      input.replaceAll(RegExp(r'[\s\-]'), '');

  static bool isValid(String input) => _pattern.hasMatch(normalize(input));
}
