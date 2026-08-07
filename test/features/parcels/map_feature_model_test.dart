import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/parcels/data/models/map_feature_model.dart';

void main() {
  test('parses a GeoJSON feature with properties and geometry', () {
    final model = MapFeatureModel.fromFeature({
      'type': 'Feature',
      'geometry': {
        'type': 'MultiPolygon',
        'coordinates': [
          [
            [
              [46.44, 24.74],
              [46.45, 24.74],
              [46.45, 24.75],
              [46.44, 24.74],
            ],
          ],
        ],
      },
      'properties': {
        'id': 33,
        'parcel_no': '749',
        'asset_type': 'أرض',
        'district': 'الوصيل',
        'deed_no': '396426002606',
        'deed_status': 'محدث',
        'area_sqm': 3000,
      },
    });

    expect(model.id, 33);
    expect(model.parcelNo, '749');
    expect(model.deedStatus, 'محدث');
    expect(model.polygons, hasLength(1));
    expect(model.polygons.first.first.latitude, 24.74);
  });
}
