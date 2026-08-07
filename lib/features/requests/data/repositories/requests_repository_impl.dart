import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/paginated_data.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/modification_request.dart';
import '../../domain/repositories/requests_repository.dart';
import '../models/modification_request_model.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  final ApiClient client;
  const RequestsRepositoryImpl(this.client);

  @override
  Future<PaginatedData<ModificationRequestItem>> getRequests({
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await client.get(ApiEndpoints.modificationRequests, query: {
      'page': '$page',
      'per_page': '$perPage',
    });
    return PaginatedData.fromJson(res, ModificationRequestModel.fromJson);
  }

  @override
  Future<ModificationRequestItem> createRequest({
    required int parcelId,
    required String fieldName,
    required String newValue,
    String? notes,
  }) async {
    final res = await client.post(ApiEndpoints.modificationRequests, body: {
      'parcel_id': parcelId,
      'field_name': fieldName,
      'new_value': newValue,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return ModificationRequestModel.fromJson(
        (res['data'] as Map<String, dynamic>?) ?? const {});
  }
}
