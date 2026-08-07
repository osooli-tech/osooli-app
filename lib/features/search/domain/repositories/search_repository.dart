import '../entities/search_result.dart';

abstract class SearchRepository {
  /// [type] is one of the API's axes: deed (default), parcel, plan, owner.
  Future<List<SearchResult>> search({required String query, required String type});
}
