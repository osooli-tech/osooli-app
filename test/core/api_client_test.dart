import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sakukiapp/core/errors/api_exception.dart';
import 'package:sakukiapp/core/network/api_client.dart';
import 'package:sakukiapp/core/storage/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  String? stored;
  FakeTokenStorage([this.stored]);
  @override
  Future<String?> get token async => stored;
  @override
  Future<Map<String, dynamic>?> get ownerJson async => null;
  @override
  Future<void> saveSession(
      {required String token, required Map<String, dynamic> ownerJson}) async {}
  @override
  Future<void> clear() async => stored = null;
}

void main() {
  test('post sends json body and returns decoded envelope', () async {
    late http.Request captured;
    final client = ApiClient(
      tokenStorage: FakeTokenStorage(),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {'message': 'ok', 'expires_in': 300}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await client.post('/auth/request-otp',
        body: {'phone': '0511111111'}, authorized: false);

    expect(captured.url.toString(), '${ApiClient.baseUrl}/auth/request-otp');
    expect(captured.headers['Accept-Language'], 'ar');
    expect(captured.headers.containsKey('Authorization'), isFalse);
    expect(jsonDecode(captured.body)['phone'], '0511111111');
    expect(result['data']['expires_in'], 300);
  });

  test('attaches bearer token when authorized', () async {
    late http.Request captured;
    final client = ApiClient(
      tokenStorage: FakeTokenStorage('17|abc'),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode({'data': {}}), 200);
      }),
    );

    await client.get('/me');
    expect(captured.headers['Authorization'], 'Bearer 17|abc');
  });

  test('throws ApiException with body on 422', () async {
    final client = ApiClient(
      tokenStorage: FakeTokenStorage(),
      httpClient: MockClient((request) async => http.Response(
            jsonEncode({
              'message': 'Invalid verification code',
              'errors': {
                'otp': ['Invalid verification code']
              }
            }),
            422,
          )),
    );

    expect(
      () => client.post('/auth/verify-otp', body: {}, authorized: false),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 422)
          .having((e) => e.firstError('otp'), 'otp error',
              'Invalid verification code')),
    );
  });

  test('fires onUnauthorized on 401', () async {
    var fired = false;
    final client = ApiClient(
      tokenStorage: FakeTokenStorage('17|abc'),
      onUnauthorized: () => fired = true,
      httpClient: MockClient((request) async =>
          http.Response(jsonEncode({'message': 'Unauthenticated.'}), 401)),
    );

    await expectLater(() => client.get('/me'), throwsA(isA<ApiException>()));
    expect(fired, isTrue);
  });
}
