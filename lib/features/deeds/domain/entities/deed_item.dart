class DeedItem {
  final int id;
  final String deedNo;
  final String? dateHijri;
  final double? areaSqm;
  final String? status;
  final String? deedClass;
  final int? parcelId;
  final String? parcelNo;
  final String? planNo;
  final String? city;
  final String? district;
  final int? documentId;

  const DeedItem({
    required this.id,
    required this.deedNo,
    this.dateHijri,
    this.areaSqm,
    this.status,
    this.deedClass,
    this.parcelId,
    this.parcelNo,
    this.planNo,
    this.city,
    this.district,
    this.documentId,
  });

  bool get hasDocument => documentId != null;
}
