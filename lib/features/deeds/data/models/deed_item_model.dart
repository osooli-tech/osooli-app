import '../../domain/entities/deed_item.dart';

class DeedItemModel extends DeedItem {
  const DeedItemModel({
    required super.id,
    required super.deedNo,
    super.dateHijri,
    super.areaSqm,
    super.status,
    super.deedClass,
    super.parcelId,
    super.parcelNo,
    super.planNo,
    super.city,
    super.district,
    super.documentId,
  });

  factory DeedItemModel.fromJson(Map<String, dynamic> json) {
    final parcel = json['parcel'] as Map<String, dynamic>?;
    final document = json['document'] as Map<String, dynamic>?;
    return DeedItemModel(
      id: json['id'] as int,
      deedNo: json['deed_no']?.toString() ?? '',
      dateHijri: json['deed_date_hijri'] as String?,
      areaSqm: (json['deed_area_sqm'] as num?)?.toDouble(),
      status: json['deed_status'] as String?,
      deedClass: json['deed_class'] as String?,
      parcelId: (parcel?['id'] as num?)?.toInt(),
      parcelNo: parcel?['parcel_no']?.toString(),
      planNo: parcel?['plan_no']?.toString(),
      city: parcel?['city'] as String?,
      district: parcel?['district'] as String?,
      documentId: (document?['id'] as num?)?.toInt(),
    );
  }
}
