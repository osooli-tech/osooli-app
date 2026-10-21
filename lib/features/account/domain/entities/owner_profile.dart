import '../../../auth/domain/entities/owner.dart';

class ProfileStats {
  final int parcelsCount;
  final int deedsCount;
  final int documentsCount;

  const ProfileStats({
    this.parcelsCount = 0,
    this.deedsCount = 0,
    this.documentsCount = 0,
  });
}

class OwnerProfile extends Owner {
  final ProfileStats stats;

  const OwnerProfile({
    required super.id,
    required super.name,
    required super.nationalId,
    required super.phone,
    super.email,
    this.stats = const ProfileStats(),
  });
}
