import '../../domain/entities/map_feature.dart';
import 'parcel_models.dart';

class MapFeatureModel extends MapFeature {
  const MapFeatureModel({
    required super.id,
    required super.parcelNo,
    super.assetType,
    super.district,
    super.deedNo,
    super.deedStatus,
    super.areaSqm,
    super.polygons,
  });

  /// Parses one GeoJSON Feature from the `/parcels/map` FeatureCollection.
  factory MapFeatureModel.fromFeature(Map<String, dynamic> feature) {
    final props =
        (feature['properties'] as Map<String, dynamic>?) ?? const {};
    return MapFeatureModel(
      id: (props['id'] as num?)?.toInt() ?? 0,
      parcelNo: props['parcel_no']?.toString() ?? '',
      assetType: props['asset_type'] as String?,
      district: props['district'] as String?,
      deedNo: props['deed_no']?.toString(),
      deedStatus: props['deed_status'] as String?,
      areaSqm: (props['area_sqm'] as num?)?.toDouble(),
      polygons: ParcelDetailModel.parseMultiPolygon(feature['geometry']),
    );
  }
}
