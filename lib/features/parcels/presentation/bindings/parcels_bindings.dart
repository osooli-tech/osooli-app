import 'package:get/get.dart';

import '../../../../core/services/document_service.dart';
import '../../domain/repositories/parcels_repository.dart';
import '../../domain/usecases/get_parcel_detail.dart';
import '../../domain/usecases/get_parcels.dart';
import '../controllers/parcel_aggregates_controller.dart';
import '../controllers/parcel_detail_controller.dart';
import '../controllers/parcels_list_controller.dart';

class ParcelsBinding extends Bindings {
  @override
  void dependencies() {
    // Fresh controller per visit so route arguments (city/status filters)
    // always take effect.
    Get.lazyPut(
        () => ParcelsListController(GetParcels(Get.find<ParcelsRepository>())));
  }
}

class ParcelAggregatesBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<ParcelsRepository>();
    Get.lazyPut(() => ParcelAggregatesController(
          getParcels: GetParcels(repo),
          getParcelDetail: GetParcelDetail(repo),
          documentService: Get.find<DocumentService>(),
        ));
  }
}

class ParcelDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ParcelDetailController(
          GetParcelDetail(Get.find<ParcelsRepository>()),
          Get.find<DocumentService>(),
        ));
  }
}
