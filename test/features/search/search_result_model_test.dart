import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/features/search/data/models/search_result_model.dart';

void main() {
  test('parses a search hit', () {
    final model = SearchResultModel.fromJson({
      'type': 'parcel',
      'id': 34,
      'title': 'رقم القطعة 748',
      'subtitle': 'رقم الصك 396426002607 · الدرعية / الوصيل',
      'badge': 'محدث',
    });

    expect(model.type, 'parcel');
    expect(model.id, 34);
    expect(model.title, 'رقم القطعة 748');
    expect(model.badge, 'محدث');
  });
}
