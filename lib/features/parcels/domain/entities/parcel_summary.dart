class ParcelSummary {
  final int id;
  final String parcelNo;
  final String? assetType;
  final String? planNo;
  final String? city;
  final String? district;
  final double? areaSqm;
  final String? deedStatus;
  final String? deedDateHijri;
  final String? deedNo;
  final int? documentsCount;

  const ParcelSummary({
    required this.id,
    required this.parcelNo,
    this.assetType,
    this.planNo,
    this.city,
    this.district,
    this.areaSqm,
    this.deedStatus,
    this.deedDateHijri,
    this.deedNo,
    this.documentsCount,
  });
}
