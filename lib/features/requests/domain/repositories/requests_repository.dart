import '../../../../core/models/paginated_data.dart';
import '../entities/modification_request.dart';

abstract class RequestsRepository {
  Future<PaginatedData<ModificationRequestItem>> getRequests({
    int page = 1,
    int perPage = 20,
  });

  Future<ModificationRequestItem> createRequest({
    required int parcelId,
    required String fieldName,
    required String newValue,
    String? notes,
  });
}
