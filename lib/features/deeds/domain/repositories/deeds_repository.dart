import '../../../../core/models/paginated_data.dart';
import '../entities/deed_item.dart';

abstract class DeedsRepository {
  /// [status] is the API's filter: `all`, `active` (محدث) or `expired` (قديم).
  Future<PaginatedData<DeedItem>> getDeeds({
    int page = 1,
    int perPage = 20,
    String status = 'all',
    String? search,
  });
}
