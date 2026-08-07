import 'package:get/get.dart';

import '../../../parcels/domain/repositories/parcels_repository.dart';
import '../../../parcels/domain/usecases/get_parcel_detail.dart';
import '../../../parcels/domain/usecases/get_parcels.dart';
import '../controllers/compare_controller.dart';

class CompareBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<ParcelsRepository>();
    Get.lazyPut(() => CompareController(
          getParcels: GetParcels(repo),
          getParcelDetail: GetParcelDetail(repo),
        ));
  }
}
