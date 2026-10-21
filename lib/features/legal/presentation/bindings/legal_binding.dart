import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/legal_repository.dart';
import '../controllers/legal_controller.dart';

class LegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
        () => LegalController(LegalRepository(Get.find<ApiClient>())));
  }
}
