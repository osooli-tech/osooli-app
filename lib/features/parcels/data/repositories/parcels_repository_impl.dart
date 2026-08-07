import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/paginated_data.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/parcel_detail.dart';
import '../../domain/entities/parcel_summary.dart';
import '../../domain/repositories/parcels_repository.dart';
import '../models/parcel_models.dart';

class ParcelsRepositoryImpl implements ParcelsRepository {
  final ApiClient client;
  const ParcelsRepositoryImpl(this.client);

  @override
  Future<PaginatedData<ParcelSummary>> getParcels({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final res = await client.get(ApiEndpoints.parcels, query: {
      'page': '$page',
      'per_page': '$perPage',
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return PaginatedData.fromJson(res, ParcelSummaryModel.fromJson);
  }

  @override
  Future<ParcelDetail> getParcelDetail(int id) async {
    final res = await client.get(ApiEndpoints.parcel(id));
    return ParcelDetailModel.fromJson(
        (res['data'] as Map<String, dynamic>?) ?? const {});
  }
}
