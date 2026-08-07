import 'package:latlong2/latlong.dart';

import 'parcel_summary.dart';

class ParcelOwner {
  final int id;
  final String name;
  final String? nationalId;
  final String? ownershipShare;

  const ParcelOwner({
    required this.id,
    required this.name,
    this.nationalId,
    this.ownershipShare,
  });
}

class ParcelDeed {
  final int id;
  final String deedNo;
  final String? dateHijri;
  final double? areaSqm;
  final String? status;
  final String? deedClass;
  final bool isCurrent;

  const ParcelDeed({
    required this.id,
    required this.deedNo,
    this.dateHijri,
    this.areaSqm,
    this.status,
    this.deedClass,
    this.isCurrent = false,
  });
}

class BoundarySide {
  final String? description;
  final double? lengthM;

  const BoundarySide({this.description, this.lengthM});
}

class ParcelBoundary {
  final BoundarySide? north;
  final BoundarySide? south;
  final BoundarySide? east;
  final BoundarySide? west;
  final double? measuredAreaSqm;
  final bool? matchesDeed;
  final String? engineeringOffice;

  const ParcelBoundary({
    this.north,
    this.south,
    this.east,
    this.west,
    this.measuredAreaSqm,
    this.matchesDeed,
    this.engineeringOffice,
  });

  bool get isEmpty =>
      north == null && south == null && east == null && west == null;
}

class SurveyDecision {
  final String? qrarNo;
  final String? reportNo;
  final String? source;
  final String? folder;

  const SurveyDecision({this.qrarNo, this.reportNo, this.source, this.folder});

  bool get isEmpty =>
      qrarNo == null && reportNo == null && source == null && folder == null;
}

class ParcelDocument {
  final int id;
  final String? type;
  final String? fileType;
  final String? downloadUrl;
  final String? createdAt;

  const ParcelDocument({
    required this.id,
    this.type,
    this.fileType,
    this.downloadUrl,
    this.createdAt,
  });
}

class ParcelDetail extends ParcelSummary {
  final String? geoId;
  final String? landTransaction;
  final String? allocationMethod;
  final String? fallIn;

  /// Outer ring of each polygon in the parcel's MultiPolygon, ready for the map.
  final List<List<LatLng>> polygons;
  final LatLng? centroid;

  final List<ParcelOwner> owners;
  final List<ParcelDeed> deeds;
  final ParcelBoundary? boundary;
  final SurveyDecision? surveyDecision;
  final List<ParcelDocument> documents;

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
    super.deedNo,
    super.documentsCount,
    this.geoId,
    this.landTransaction,
    this.allocationMethod,
    this.fallIn,
    this.polygons = const [],
    this.centroid,
    this.owners = const [],
    this.deeds = const [],
    this.boundary,
    this.surveyDecision,
    this.documents = const [],
  });
}
