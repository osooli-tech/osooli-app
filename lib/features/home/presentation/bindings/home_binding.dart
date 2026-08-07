import 'package:get/get.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<AuthRepository>();
    Get.lazyPut(() => HomeController(repository: repo, logout: Logout(repo)));
  }
}
