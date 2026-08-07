import '../../../../core/models/paginated_data.dart';
import '../entities/map_feature.dart';
import '../entities/parcel_detail.dart';
import '../entities/parcel_summary.dart';

abstract class ParcelsRepository {
  Future<PaginatedData<ParcelSummary>> getParcels({
    int page = 1,
    int perPage = 20,
    String? search,
    String? city,
  });

  Future<ParcelDetail> getParcelDetail(int id);

  /// All of the owner's parcels as map geometry (not paginated).
  Future<List<MapFeature>> getMapFeatures();
}
