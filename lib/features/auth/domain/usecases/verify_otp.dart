import '../entities/owner.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;
  const VerifyOtp(this.repository);

  Future<Owner> call({required String phone, required String otp}) =>
      repository.verifyOtp(phone: phone, otp: otp);
}
