class ApiException implements Exception {
  final int? statusCode;

  /// Either server-provided text (already localized via Accept-Language)
  /// or a translation key (error_*). UI calls .tr, which passes plain
  /// strings through unchanged.
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ApiException({
    this.statusCode,
    required this.message,
    this.fieldErrors = const {},
  });

  factory ApiException.fromResponse(int statusCode, Map<String, dynamic>? body) {
    final errors = <String, List<String>>{};
    final raw = body?['errors'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          errors['$key'] = value.map((e) => '$e').toList();
        }
      });
    }
    final message = body?['message'] as String? ?? _fallbackFor(statusCode);
    return ApiException(
      statusCode: statusCode,
      message: message,
      fieldErrors: errors,
    );
  }

  const ApiException.network()
      : statusCode = null,
        message = 'error_network',
        fieldErrors = const {};

  static String _fallbackFor(int statusCode) {
    switch (statusCode) {
      case 429:
        return 'error_rate_limited';
      case 401:
        return 'error_unauthorized';
      default:
        return 'error_server';
    }
  }

  String? firstError(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  @override
  String toString() => 'ApiException($statusCode, $message)';
}
