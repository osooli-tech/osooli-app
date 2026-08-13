import 'package:latlong2/latlong.dart';

/// One parcel from the GeoJSON map layer (`GET /parcels/map`).
class MapFeature {
  final int id;
  final String parcelNo;
  final String? assetType;
  final String? district;
  final String? city;
  final String? planNo;
  final String? deedNo;
  final String? deedStatus;
  final double? areaSqm;
  final double? mPrice;
  final double? parcelPrice;

  /// First recorded owner on the latest deed — used to color parcels.
  final String? ownerName;
  final List<List<LatLng>> polygons;

  const MapFeature({
    required this.id,
    required this.parcelNo,
    this.assetType,
    this.district,
    this.city,
    this.planNo,
    this.deedNo,
    this.deedStatus,
    this.areaSqm,
    this.mPrice,
    this.parcelPrice,
    this.ownerName,
    this.polygons = const [],
  });
}
