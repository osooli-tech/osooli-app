import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/core/errors/api_exception.dart';
import 'package:sakukiapp/core/storage/token_storage.dart';
import 'package:sakukiapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sakukiapp/features/auth/data/models/owner_model.dart';
import 'package:sakukiapp/features/auth/data/repositories/auth_repository_impl.dart';

class MemoryTokenStorage implements TokenStorage {
  String? storedToken;
  Map<String, dynamic>? storedOwner;

  @override
  Future<void> saveSession(
      {required String token, required Map<String, dynamic> ownerJson}) async {
    storedToken = token;
    storedOwner = ownerJson;
  }

  @override
  Future<String?> get token async => storedToken;

  @override
  Future<Map<String, dynamic>?> get ownerJson async => storedOwner;

  @override
  Future<void> clear() async {
    storedToken = null;
    storedOwner = null;
  }
}

const _owner = OwnerModel(
  id: 33,
  name: 'محمد',
  nationalId: '1006272601',
  phone: '0511111111',
);

class FakeRemote implements AuthRemoteDataSource {
  bool logoutThrows = false;
  bool logoutCalled = false;

  @override
  Future<int> requestOtp(String phone) async => 300;

  @override
  Future<({String token, OwnerModel owner})> verifyOtp(
          {required String phone, required String otp}) async =>
      (token: '17|abc', owner: _owner);

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutThrows) {
      throw const ApiException(statusCode: 500, message: 'error_server');
    }
  }
}

void main() {
  test('verifyOtp persists token and owner', () async {
    final storage = MemoryTokenStorage();
    final repo = AuthRepositoryImpl(remote: FakeRemote(), storage: storage);

    final owner = await repo.verifyOtp(phone: '0511111111', otp: '6666');

    expect(owner.id, 33);
    expect(storage.storedToken, '17|abc');
    expect(storage.storedOwner?['national_id'], '1006272601');
    expect(await repo.hasSession(), isTrue);
    expect((await repo.savedOwner())?.name, 'محمد');
  });

  test('logout clears session even when server errors', () async {
    final storage = MemoryTokenStorage();
    final remote = FakeRemote()..logoutThrows = true;
    final repo = AuthRepositoryImpl(remote: remote, storage: storage);
    await repo.verifyOtp(phone: '0511111111', otp: '6666');

    await repo.logout();

    expect(remote.logoutCalled, isTrue);
    expect(storage.storedToken, isNull);
    expect(await repo.hasSession(), isFalse);
  });
}
