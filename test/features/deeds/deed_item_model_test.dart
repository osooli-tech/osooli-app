import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/deeds/data/models/deed_item_model.dart';

void main() {
  test('parses the deeds list payload shape', () {
    final model = DeedItemModel.fromJson({
      'id': 34,
      'deed_no': '396426002607',
      'deed_date_hijri': '1443-03-28',
      'deed_area_sqm': 3000,
      'deed_status': 'محدث',
      'deed_class': 'زراعي',
      'parcel': {
        'id': 34,
        'parcel_no': '748',
        'plan_no': '2',
        'city': 'الدرعية',
        'district': 'الوصيل',
      },
      'document': {
        'id': 83,
        'download_url': 'https://x/api/v1/documents/83/download',
      },
    });

    expect(model.deedNo, '396426002607');
    expect(model.areaSqm, 3000.0);
    expect(model.parcelNo, '748');
    expect(model.city, 'الدرعية');
    expect(model.documentId, 83);
    expect(model.hasDocument, isTrue);
  });

  test('tolerates null parcel and document', () {
    final model = DeedItemModel.fromJson(const {'id': 1, 'deed_no': '5'});
    expect(model.parcelId, isNull);
    expect(model.hasDocument, isFalse);
  });
}
