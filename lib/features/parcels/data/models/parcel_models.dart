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
    super.deedNo,
    super.documentsCount,
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
      deedNo: deed?['deed_no']?.toString(),
      documentsCount: (json['documents_count'] as num?)?.toInt(),
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
    super.deedNo,
    super.documentsCount,
    super.geoId,
    super.landTransaction,
    super.allocationMethod,
    super.fallIn,
    super.polygons,
    super.centroid,
    super.owners,
    super.deeds,
    super.boundary,
    super.surveyDecision,
    super.documents,
  });

  factory ParcelDetailModel.fromJson(Map<String, dynamic> json) {
    final deeds = (json['deeds'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_deed)
        .toList();
    final current = deeds.firstWhere(
      (d) => d.isCurrent,
      orElse: () => deeds.isEmpty
          ? const ParcelDeed(id: 0, deedNo: '')
          : deeds.first,
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
      areaSqm: current.areaSqm,
      deedStatus: current.status,
      deedDateHijri: current.dateHijri,
      deedNo: current.id == 0 ? null : current.deedNo,
      geoId: json['geo_id']?.toString(),
      landTransaction: json['land_transaction'] as String?,
      allocationMethod: json['allocation_method'] as String?,
      fallIn: json['fall_in'] as String?,
      polygons: _parseMultiPolygon(json['geometry']),
      centroid: centroid,
      owners: (json['owners'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((row) => ParcelOwner(
                id: (row['id'] as num?)?.toInt() ?? 0,
                name: row['name'] as String? ?? '',
                nationalId: row['national_id']?.toString(),
                ownershipShare: row['ownership_share']?.toString(),
              ))
          .toList(),
      deeds: deeds,
      boundary: _boundary(json['boundary']),
      surveyDecision: _surveyDecision(json['survey_decision']),
      documents: (json['documents'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((row) => ParcelDocument(
                id: (row['id'] as num?)?.toInt() ?? 0,
                type: row['type'] as String?,
                fileType: row['file_type'] as String?,
                downloadUrl: row['download_url'] as String?,
                createdAt: row['created_at'] as String?,
              ))
          .toList(),
    );
  }

  static ParcelDeed _deed(Map<String, dynamic> row) => ParcelDeed(
        id: (row['id'] as num?)?.toInt() ?? 0,
        deedNo: row['deed_no']?.toString() ?? '',
        dateHijri: row['deed_date_hijri'] as String?,
        areaSqm: (row['deed_area_sqm'] as num?)?.toDouble(),
        status: row['deed_status'] as String?,
        deedClass: row['deed_class'] as String?,
        isCurrent: row['is_current'] == true,
      );

  static ParcelBoundary? _boundary(Object? value) {
    if (value is! Map<String, dynamic>) return null;

    BoundarySide? side(Object? raw) {
      if (raw is! Map<String, dynamic>) return null;
      return BoundarySide(
        description: raw['description'] as String?,
        lengthM: (raw['length_m'] as num?)?.toDouble(),
      );
    }

    final boundary = ParcelBoundary(
      north: side(value['north']),
      south: side(value['south']),
      east: side(value['east']),
      west: side(value['west']),
      measuredAreaSqm: (value['measured_area_sqm'] as num?)?.toDouble(),
      matchesDeed: value['matches_deed'] as bool?,
      engineeringOffice: value['engineering_office'] as String?,
    );
    return boundary.isEmpty && boundary.engineeringOffice == null
        ? null
        : boundary;
  }

  static SurveyDecision? _surveyDecision(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final decision = SurveyDecision(
      qrarNo: value['qrar_no']?.toString(),
      reportNo: value['report_no']?.toString(),
      source: value['qrar_source'] as String?,
      folder: value['folder'] as String?,
    );
    return decision.isEmpty ? null : decision;
  }

  /// GeoJSON MultiPolygon coordinates are
  /// polygons -> rings -> positions([lng, lat]). Keeps each polygon's outer
  /// ring only — holes are irrelevant at this zoom level.
  static List<List<LatLng>> parseMultiPolygon(Object? geometry) =>
      _parseMultiPolygon(geometry);

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
