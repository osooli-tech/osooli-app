import 'package:get/get.dart';

import '../../domain/repositories/requests_repository.dart';
import '../../domain/usecases/get_requests.dart';
import '../controllers/requests_controller.dart';

class RequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
        () => RequestsController(GetRequests(Get.find<RequestsRepository>())));
  }
}
