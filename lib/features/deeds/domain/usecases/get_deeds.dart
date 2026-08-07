import '../../../../core/models/paginated_data.dart';
import '../entities/deed_item.dart';
import '../repositories/deeds_repository.dart';

class GetDeeds {
  final DeedsRepository repository;
  const GetDeeds(this.repository);

  Future<PaginatedData<DeedItem>> call({
    int page = 1,
    int perPage = 20,
    String status = 'all',
    String? search,
  }) =>
      repository.getDeeds(
          page: page, perPage: perPage, status: status, search: search);
}
