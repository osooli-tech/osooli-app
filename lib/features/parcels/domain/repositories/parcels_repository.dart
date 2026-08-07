import '../../../../core/models/paginated_data.dart';
import '../entities/parcel_detail.dart';
import '../entities/parcel_summary.dart';

abstract class ParcelsRepository {
  Future<PaginatedData<ParcelSummary>> getParcels({
    int page = 1,
    int perPage = 20,
    String? search,
  });

  Future<ParcelDetail> getParcelDetail(int id);
}
