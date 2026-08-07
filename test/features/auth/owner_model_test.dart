import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/auth/data/models/owner_model.dart';

void main() {
  test('fromJson/toJson round-trips', () {
    final json = {
      'id': 33,
      'name': 'محمد عبدالله الحقباني',
      'national_id': '1006272601',
      'phone': '0511111111',
      'email': null,
    };
    final model = OwnerModel.fromJson(json);
    expect(model.id, 33);
    expect(model.nationalId, '1006272601');
    expect(model.email, isNull);
    expect(model.toJson(), json);
  });
}
