import '../entities/owner.dart';

abstract class AuthRepository {
  /// Returns the OTP expiry in seconds.
  Future<int> requestOtp(String phone);

  /// Verifies the code, persists the session, returns the owner.
  Future<Owner> verifyOtp({required String phone, required String otp});

  /// Revokes the token server-side (best effort) and clears local session.
  Future<void> logout();

  Future<Owner?> savedOwner();

  Future<bool> hasSession();
}
