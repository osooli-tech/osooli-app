import '../entities/parcel_detail.dart';
import '../repositories/parcels_repository.dart';

class GetParcelDetail {
  final ParcelsRepository repository;
  const GetParcelDetail(this.repository);

  Future<ParcelDetail> call(int id) => repository.getParcelDetail(id);
}
