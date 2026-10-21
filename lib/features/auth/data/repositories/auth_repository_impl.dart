import '../../../../core/errors/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/owner.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/owner_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage storage;

  const AuthRepositoryImpl({required this.remote, required this.storage});

  @override
  Future<int> requestOtp(String phone) => remote.requestOtp(phone);

  @override
  Future<Owner> verifyOtp({required String phone, required String otp}) async {
    final result = await remote.verifyOtp(phone: phone, otp: otp);
    await storage.saveSession(
      token: result.token,
      ownerJson: result.owner.toJson(),
    );
    return result.owner;
  }

  @override
  Future<void> logout() async {
    try {
      await remote.logout();
    } on ApiException {
      // Local sign-out must succeed even if the server call fails.
    }
    await storage.clear();
  }

  @override
  Future<Owner?> savedOwner() async {
    final json = await storage.ownerJson;
    return json == null ? null : OwnerModel.fromJson(json);
  }

  @override
  Future<bool> hasSession() async => await storage.token != null;
}
