import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../models/search_result_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final ApiClient client;
  const SearchRepositoryImpl(this.client);

  @override
  Future<List<SearchResult>> search(
      {required String query, required String type}) async {
    final res = await client.get(ApiEndpoints.search, query: {
      'q': query,
      'type': type,
    });
    return (res['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SearchResultModel.fromJson)
        .toList();
  }
}
