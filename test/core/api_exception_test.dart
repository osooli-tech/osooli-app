import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/core/errors/api_exception.dart';

void main() {
  test('fromResponse reads message and field errors', () {
    final e = ApiException.fromResponse(422, {
      'message': 'Invalid verification code',
      'errors': {
        'otp': ['Invalid verification code']
      },
    });
    expect(e.statusCode, 422);
    expect(e.message, 'Invalid verification code');
    expect(e.firstError('otp'), 'Invalid verification code');
    expect(e.firstError('phone'), isNull);
  });

  test('fromResponse falls back to generic message key', () {
    final e = ApiException.fromResponse(500, null);
    expect(e.message, 'error_server');
  });

  test('fromResponse maps 429 to rate limit key', () {
    final e = ApiException.fromResponse(429, null);
    expect(e.message, 'error_rate_limited');
  });
}
