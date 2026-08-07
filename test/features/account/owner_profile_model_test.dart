import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/account/data/models/owner_profile_model.dart';

void main() {
  test('parses the /me payload shape', () {
    final model = OwnerProfileModel.fromJson({
      'id': 33,
      'name': 'محمد عبدالله محمد الحقباني',
      'national_id': '1006272601',
      'phone': '0511111111',
      'email': null,
      'stats': {
        'parcels_count': 2,
        'deeds_count': 2,
        'documents_count': 2,
      },
    });

    expect(model.id, 33);
    expect(model.stats.parcelsCount, 2);
    expect(model.stats.deedsCount, 2);
    expect(model.email, isNull);
  });
}
