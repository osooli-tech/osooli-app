import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/owner_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/owner_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient client;
  const ProfileRepositoryImpl(this.client);

  @override
  Future<OwnerProfile> getProfile() async {
    final res = await client.get(ApiEndpoints.me);
    return OwnerProfileModel.fromJson(
        (res['data'] as Map<String, dynamic>?) ?? const {});
  }

  @override
  Future<OwnerProfile> updateProfile({String? email, String? whatsapp}) async {
    final res = await client.patch(ApiEndpoints.me, body: {
      if (email != null) 'email': email.isEmpty ? null : email,
      if (whatsapp != null) 'whatsapp': whatsapp.isEmpty ? null : whatsapp,
    });
    return OwnerProfileModel.fromJson(
        (res['data'] as Map<String, dynamic>?) ?? const {});
  }
}
