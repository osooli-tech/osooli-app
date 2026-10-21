import '../../../../core/network/api_client.dart';
import '../models/owner_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;
  const AuthRemoteDataSource(this._client);

  Future<int> requestOtp(String phone) async {
    final res = await _client.post(
      '/auth/request-otp',
      body: {'phone': phone},
      authorized: false,
    );
    return (res['data']?['expires_in'] as int?) ?? 300;
  }

  Future<({String token, OwnerModel owner})> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await _client.post(
      '/auth/verify-otp',
      body: {'phone': phone, 'otp': otp},
      authorized: false,
    );
    final data = res['data'] as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      owner: OwnerModel.fromJson(data['owner'] as Map<String, dynamic>),
    );
  }

  Future<void> logout() => _client.post('/auth/logout');
}
