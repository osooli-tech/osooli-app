import 'package:get/get.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../compare/presentation/controllers/compare_controller.dart';
import '../../../dashboard/domain/repositories/dashboard_repository.dart';
import '../../../dashboard/domain/usecases/get_dashboard.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../parcels/domain/repositories/parcels_repository.dart';
import '../../../parcels/domain/usecases/get_parcel_detail.dart';
import '../../../parcels/domain/usecases/get_parcels.dart';
import '../../../parcels/presentation/controllers/parcels_list_controller.dart';
import '../controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShellController());
    Get.lazyPut(
        () => DashboardController(GetDashboard(Get.find<DashboardRepository>())));
    final parcelsRepo = Get.find<ParcelsRepository>();
    Get.lazyPut(() => CompareController(
          getParcels: GetParcels(parcelsRepo),
          getParcelDetail: GetParcelDetail(parcelsRepo),
        ));
    Get.lazyPut(() => ParcelsListController(GetParcels(parcelsRepo)));
    final authRepo = Get.find<AuthRepository>();
    Get.lazyPut(
        () => HomeController(repository: authRepo, logout: Logout(authRepo)));
  }
}
