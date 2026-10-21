import '../entities/owner_profile.dart';

abstract class ProfileRepository {
  Future<OwnerProfile> getProfile();

  /// Only contact details are editable; other fields come from official
  /// records and are ignored server-side.
  Future<OwnerProfile> updateProfile({String? email, String? whatsapp});
}
