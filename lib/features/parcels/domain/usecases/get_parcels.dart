import '../../../../core/models/paginated_data.dart';
import '../entities/parcel_summary.dart';
import '../repositories/parcels_repository.dart';

class GetParcels {
  final ParcelsRepository repository;
  const GetParcels(this.repository);

  Future<PaginatedData<ParcelSummary>> call({
    int page = 1,
    int perPage = 20,
    String? search,
    String? city,
  }) =>
      repository.getParcels(
          page: page, perPage: perPage, search: search, city: city);
}
