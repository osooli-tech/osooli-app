import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/core/models/paginated_data.dart';

void main() {
  test('parses envelope with meta', () {
    final page = PaginatedData.fromJson({
      'data': [
        {'id': 1},
        {'id': 2},
      ],
      'meta': {'current_page': 1, 'per_page': 20, 'total': 25, 'last_page': 2},
    }, (json) => json['id'] as int);

    expect(page.items, [1, 2]);
    expect(page.total, 25);
    expect(page.hasMore, isTrue);
  });

  test('tolerates missing meta', () {
    final page = PaginatedData.fromJson({
      'data': [
        {'id': 7},
      ],
    }, (json) => json['id'] as int);

    expect(page.items, [7]);
    expect(page.currentPage, 1);
    expect(page.hasMore, isFalse);
  });
}
