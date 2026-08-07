import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/parcels/data/models/parcel_models.dart';

void main() {
  test('summary parses the list payload shape', () {
    final model = ParcelSummaryModel.fromJson({
      'id': 34,
      'parcel_no': '748',
      'geo_id': '748-2',
      'asset_type': 'أرض',
      'plan_no': '2',
      'city': 'الدرعية',
      'district': 'الوصيل',
      'area_sqm': 3000,
      'current_deed': {
        'id': 34,
        'deed_no': '396426002607',
        'deed_date_hijri': '1443-03-28',
        'deed_status': 'محدث',
      },
    });

    expect(model.id, 34);
    expect(model.areaSqm, 3000.0);
    expect(model.deedStatus, 'محدث');
    expect(model.deedDateHijri, '1443-03-28');
  });

  test('detail parses current deed and MultiPolygon outer rings', () {
    final model = ParcelDetailModel.fromJson({
      'id': 34,
      'parcel_no': '748',
      'asset_type': 'أرض',
      'plan_no': '2',
      'city': 'الدرعية',
      'district': 'الوصيل',
      'centroid': {'lat': 24.750100, 'lng': 46.441128},
      'geometry': {
        'type': 'MultiPolygon',
        'coordinates': [
          [
            [
              [46.440520, 24.749843],
              [46.441000, 24.749900],
              [46.441100, 24.750300],
              [46.440520, 24.749843],
            ],
          ],
        ],
      },
      'deeds': [
        {
          'id': 30,
          'deed_status': 'قديم',
          'deed_date_hijri': '1420-01-01',
          'deed_area_sqm': 2900,
          'is_current': false,
        },
        {
          'id': 34,
          'deed_status': 'محدث',
          'deed_date_hijri': '1443-03-28',
          'deed_area_sqm': 3000,
          'is_current': true,
        },
      ],
    });

    expect(model.deedStatus, 'محدث');
    expect(model.areaSqm, 3000.0);
    expect(model.polygons, hasLength(1));
    expect(model.polygons.first, hasLength(4));
    // GeoJSON order is [lng, lat] — verify the swap happened.
    expect(model.polygons.first.first.latitude, 24.749843);
    expect(model.polygons.first.first.longitude, 46.440520);
    expect(model.centroid?.latitude, 24.750100);
  });

  test('detail tolerates missing geometry and deeds', () {
    final model = ParcelDetailModel.fromJson(const {'id': 1, 'parcel_no': '5'});
    expect(model.polygons, isEmpty);
    expect(model.deedStatus, isNull);
    expect(model.centroid, isNull);
  });
}
