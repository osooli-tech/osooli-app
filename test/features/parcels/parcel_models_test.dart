import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/features/parcels/data/models/parcel_models.dart';

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
      'geo_id': '748-2',
      'asset_type': 'أرض',
      'land_transaction': 'خاصة',
      'allocation_method': 'محدد بدقة',
      'fall_in': 'مخطط زراعي',
      'plan_no': '2',
      'city': 'الدرعية',
      'district': 'الوصيل',
      'centroid': {'lat': 24.750100, 'lng': 46.441128},
      'owners': [
        {
          'id': 33,
          'name': 'محمد عبدالله',
          'national_id': '1006272601',
          'ownership_share': null,
        }
      ],
      'boundary': {
        'north': {'description': 'شارع عرض 15 متر', 'length_m': 50},
        'south': {'description': 'قطعة رقم 409', 'length_m': 50},
        'east': {'description': 'قطعة رقم 400', 'length_m': 60},
        'west': {'description': 'شارع عرض 20 متر', 'length_m': 60},
        'measured_area_sqm': null,
        'matches_deed': null,
        'engineering_office': 'مكتب الإسناد العالمي',
      },
      'survey_decision': {
        'qrar_no': null,
        'report_no': null,
        'qrar_source': 'مكتب هندسي',
        'folder': 'قرارات',
      },
      'documents': [
        {
          'id': 83,
          'type': 'صك',
          'file_type': 'pdf',
          'download_url': 'https://x/api/v1/documents/83/download',
          'created_at': '2026-07-19T11:54:36+00:00',
        }
      ],
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
    expect(model.geoId, '748-2');
    expect(model.landTransaction, 'خاصة');
    expect(model.owners.single.name, 'محمد عبدالله');
    expect(model.deeds, hasLength(2));
    expect(model.boundary?.north?.description, 'شارع عرض 15 متر');
    expect(model.boundary?.engineeringOffice, 'مكتب الإسناد العالمي');
    expect(model.surveyDecision?.source, 'مكتب هندسي');
    expect(model.documents.single.type, 'صك');
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
    expect(model.owners, isEmpty);
    expect(model.boundary, isNull);
    expect(model.surveyDecision, isNull);
    expect(model.documents, isEmpty);
    expect(model.deedNo, isNull);
  });
}
