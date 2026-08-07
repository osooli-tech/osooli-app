import 'package:latlong2/latlong.dart';

import 'parcel_summary.dart';

class ParcelDetail extends ParcelSummary {
  /// Outer ring of each polygon in the parcel's MultiPolygon, ready for the map.
  final List<List<LatLng>> polygons;
  final LatLng? centroid;

  const ParcelDetail({
    required super.id,
    required super.parcelNo,
    super.assetType,
    super.planNo,
    super.city,
    super.district,
    super.areaSqm,
    super.deedStatus,
    super.deedDateHijri,
    this.polygons = const [],
    this.centroid,
  });
}
