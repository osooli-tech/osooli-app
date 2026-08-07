import '../../domain/entities/owner_profile.dart';

class OwnerProfileModel extends OwnerProfile {
  const OwnerProfileModel({
    required super.id,
    required super.name,
    required super.nationalId,
    required super.phone,
    super.email,
    super.stats,
  });

  factory OwnerProfileModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? const {};
    return OwnerProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      nationalId: json['national_id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email'] as String?,
      stats: ProfileStats(
        parcelsCount: (stats['parcels_count'] as num?)?.toInt() ?? 0,
        deedsCount: (stats['deeds_count'] as num?)?.toInt() ?? 0,
        documentsCount: (stats['documents_count'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
