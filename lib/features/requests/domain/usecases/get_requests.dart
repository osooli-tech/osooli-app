import '../../../../core/models/paginated_data.dart';
import '../entities/modification_request.dart';
import '../repositories/requests_repository.dart';

class GetRequests {
  final RequestsRepository repository;
  const GetRequests(this.repository);

  Future<PaginatedData<ModificationRequestItem>> call({
    int page = 1,
    int perPage = 20,
  }) =>
      repository.getRequests(page: page, perPage: perPage);
}
