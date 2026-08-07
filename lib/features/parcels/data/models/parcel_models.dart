import 'package:latlong2/latlong.dart';

import '../../domain/entities/parcel_detail.dart';
import '../../domain/entities/parcel_summary.dart';

class ParcelSummaryModel extends ParcelSummary {
  const ParcelSummaryModel({
    required super.id,
    required super.parcelNo,
    super.assetType,
    super.planNo,
    super.city,
    super.district,
    super.areaSqm,
    super.deedStatus,
    super.deedDateHijri,
  });

  factory ParcelSummaryModel.fromJson(Map<String, dynamic> json) {
    final deed = json['current_deed'] as Map<String, dynamic>?;
    return ParcelSummaryModel(
      id: json['id'] as int,
      parcelNo: json['parcel_no']?.toString() ?? '',
      assetType: json['asset_type'] as String?,
      planNo: json['plan_no']?.toString(),
      city: json['city'] as String?,
      district: json['district'] as String?,
      areaSqm: (json['area_sqm'] as num?)?.toDouble(),
      deedStatus: deed?['deed_status'] as String?,
      deedDateHijri: deed?['deed_date_hijri'] as String?,
    );
  }
}

class ParcelDetailModel extends ParcelDetail {
  const ParcelDetailModel({
    required super.id,
    required super.parcelNo,
    super.assetType,
    super.planNo,
    super.city,
    super.district,
    super.areaSqm,
    super.deedStatus,
    super.deedDateHijri,
    super.polygons,
    super.centroid,
  });

  factory ParcelDetailModel.fromJson(Map<String, dynamic> json) {
    // The detail endpoint nests deed info in a `deeds` array (is_current
    // marks the active one) rather than `current_deed`.
    final deeds = (json['deeds'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final current = deeds.firstWhere(
      (d) => d['is_current'] == true,
      orElse: () => deeds.isEmpty ? const {} : deeds.first,
    );

    final centroidJson = json['centroid'] as Map<String, dynamic>?;
    final centroid = (centroidJson?['lat'] is num && centroidJson?['lng'] is num)
        ? LatLng(
            (centroidJson!['lat'] as num).toDouble(),
            (centroidJson['lng'] as num).toDouble(),
          )
        : null;

    return ParcelDetailModel(
      id: json['id'] as int,
      parcelNo: json['parcel_no']?.toString() ?? '',
      assetType: json['asset_type'] as String?,
      planNo: json['plan_no']?.toString(),
      city: json['city'] as String?,
      district: json['district'] as String?,
      areaSqm: (current['deed_area_sqm'] as num?)?.toDouble(),
      deedStatus: current['deed_status'] as String?,
      deedDateHijri: current['deed_date_hijri'] as String?,
      polygons: _parseMultiPolygon(json['geometry']),
      centroid: centroid,
    );
  }

  /// GeoJSON MultiPolygon coordinates are
  /// polygons -> rings -> positions([lng, lat]). Keeps each polygon's outer
  /// ring only — holes are irrelevant at this zoom level.
  static List<List<LatLng>> _parseMultiPolygon(Object? geometry) {
    if (geometry is! Map<String, dynamic>) return const [];
    final coordinates = geometry['coordinates'];
    if (coordinates is! List) return const [];

    final polygons = <List<LatLng>>[];
    for (final polygon in coordinates) {
      if (polygon is! List || polygon.isEmpty) continue;
      final ring = polygon.first;
      if (ring is! List) continue;
      final points = <LatLng>[];
      for (final position in ring) {
        if (position is List &&
            position.length >= 2 &&
            position[0] is num &&
            position[1] is num) {
          points.add(LatLng(
            (position[1] as num).toDouble(),
            (position[0] as num).toDouble(),
          ));
        }
      }
      if (points.length >= 3) polygons.add(points);
    }
    return polygons;
  }
}
