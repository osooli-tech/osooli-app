/// Generic wrapper for the API's paginated envelope:
/// `{ "data": [...], "meta": {current_page, per_page, total, last_page} }`.
class PaginatedData<T> {
  final List<T> items;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedData({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const {};
    final list = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(itemParser)
        .toList();
    return PaginatedData(
      items: list,
      currentPage: (meta['current_page'] as int?) ?? 1,
      perPage: (meta['per_page'] as int?) ?? list.length,
      total: (meta['total'] as int?) ?? list.length,
      lastPage: (meta['last_page'] as int?) ?? 1,
    );
  }
}
