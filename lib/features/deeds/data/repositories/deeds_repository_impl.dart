import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/paginated_data.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/deed_item.dart';
import '../../domain/repositories/deeds_repository.dart';
import '../models/deed_item_model.dart';

class DeedsRepositoryImpl implements DeedsRepository {
  final ApiClient client;
  const DeedsRepositoryImpl(this.client);

  @override
  Future<PaginatedData<DeedItem>> getDeeds({
    int page = 1,
    int perPage = 20,
    String status = 'all',
    String? search,
  }) async {
    final res = await client.get(ApiEndpoints.deeds, query: {
      'page': '$page',
      'per_page': '$perPage',
      if (status != 'all') 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return PaginatedData.fromJson(res, DeedItemModel.fromJson);
  }
}
