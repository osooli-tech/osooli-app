import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/requests/data/models/modification_request_model.dart';

void main() {
  test('parses a modification request row', () {
    final model = ModificationRequestModel.fromJson({
      'id': 7,
      'parcel': {'id': 34, 'parcel_no': '748'},
      'field_name': 'asset_type',
      'field_label': 'نوع الأصل',
      'old_value': 'أرض',
      'new_value': 'مبنى',
      'notes': 'تم البناء العام الماضي',
      'status': 'pending',
      'status_label': 'قيد المراجعة',
      'created_at': '2026-08-07T10:00:00+00:00',
      'resolved_at': null,
    });

    expect(model.id, 7);
    expect(model.parcelNo, '748');
    expect(model.fieldLabel, 'نوع الأصل');
    expect(model.status, 'pending');
    expect(model.statusLabel, 'قيد المراجعة');
    expect(model.resolvedAt, isNull);
  });

  test('tolerates missing parcel', () {
    final model = ModificationRequestModel.fromJson(const {'id': 1});
    expect(model.parcelId, isNull);
    expect(model.status, 'pending');
  });
}
