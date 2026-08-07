import 'package:get/get.dart';

import '../../domain/repositories/parcels_repository.dart';
import '../../domain/usecases/get_parcel_detail.dart';
import '../../domain/usecases/get_parcels.dart';
import '../controllers/parcel_detail_controller.dart';
import '../controllers/parcels_list_controller.dart';

class ParcelsBinding extends Bindings {
  @override
  void dependencies() {
    // The shell tab may have registered the list controller already —
    // the routed page then shares the same list state.
    if (!Get.isRegistered<ParcelsListController>()) {
      Get.lazyPut(
          () => ParcelsListController(GetParcels(Get.find<ParcelsRepository>())));
    }
  }
}

class ParcelDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() =>
        ParcelDetailController(GetParcelDetail(Get.find<ParcelsRepository>())));
  }
}
