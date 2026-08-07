import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchHoldings {
  final SearchRepository repository;
  const SearchHoldings(this.repository);

  Future<List<SearchResult>> call({required String query, required String type}) =>
      repository.search(query: query, type: type);
}
