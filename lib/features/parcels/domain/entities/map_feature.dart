import 'package:latlong2/latlong.dart';

/// One parcel from the GeoJSON map layer (`GET /parcels/map`).
class MapFeature {
  final int id;
  final String parcelNo;
  final String? assetType;
  final String? district;
  final String? deedNo;
  final String? deedStatus;
  final double? areaSqm;
  final List<List<LatLng>> polygons;

  const MapFeature({
    required this.id,
    required this.parcelNo,
    this.assetType,
    this.district,
    this.deedNo,
    this.deedStatus,
    this.areaSqm,
    this.polygons = const [],
  });
}
