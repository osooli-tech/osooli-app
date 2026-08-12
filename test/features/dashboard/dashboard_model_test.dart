import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/features/dashboard/data/models/dashboard_data_model.dart';

void main() {
  test('parses the real dashboard payload shape', () {
    final model = DashboardDataModel.fromJson({
      'greeting_name': 'محمد',
      'stats': {
        'parcels_total': 2,
        'deeds_active': 2,
        'deeds_expired': 0,
        'parcels_without_deed': 0,
        'survey_decisions_total': 2,
        'area_total_sqm': 6000,
        'cities_count': 1,
        'documents_count': 2,
      },
      'by_city': [
        {'name': 'الدرعية', 'parcels_count': 2}
      ],
      'by_district': [
        {'name': 'الوصيل', 'parcels_count': 2}
      ],
      'unread_notifications': 0,
    });

    expect(model.greetingName, 'محمد');
    expect(model.stats.parcelsTotal, 2);
    expect(model.stats.areaTotalSqm, 6000.0);
    expect(model.byCity.single.name, 'الدرعية');
    expect(model.byDistrict.single.parcelsCount, 2);
    expect(model.unreadNotifications, 0);
  });

  test('tolerates missing fields', () {
    final model = DashboardDataModel.fromJson(const {});
    expect(model.greetingName, '');
    expect(model.stats.parcelsTotal, 0);
    expect(model.byCity, isEmpty);
  });
}
