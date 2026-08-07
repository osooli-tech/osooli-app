import 'package:get/get.dart';

import '../../../../core/services/document_service.dart';
import '../../../../core/storage/recent_searches_storage.dart';
import '../../../account/domain/repositories/profile_repository.dart';
import '../../../account/presentation/controllers/account_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../dashboard/domain/repositories/dashboard_repository.dart';
import '../../../dashboard/domain/usecases/get_dashboard.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../deeds/domain/repositories/deeds_repository.dart';
import '../../../deeds/domain/usecases/get_deeds.dart';
import '../../../deeds/presentation/controllers/deeds_controller.dart';
import '../../../map/presentation/controllers/map_controller.dart';
import '../../../parcels/domain/repositories/parcels_repository.dart';
import '../../../parcels/domain/usecases/get_parcels.dart';
import '../../../parcels/presentation/controllers/parcels_list_controller.dart';
import '../../../search/domain/repositories/search_repository.dart';
import '../../../search/domain/usecases/search_holdings.dart';
import '../../../search/presentation/controllers/search_controller.dart';
import '../controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShellController());
    Get.lazyPut(
        () => DashboardController(GetDashboard(Get.find<DashboardRepository>())));

    final parcelsRepo = Get.find<ParcelsRepository>();
    Get.lazyPut(() => ParcelsMapController(parcelsRepo));
    Get.lazyPut(() => ParcelsListController(GetParcels(parcelsRepo)));

    Get.lazyPut(() => DeedsController(
          getDeeds: GetDeeds(Get.find<DeedsRepository>()),
          documentService: Get.find<DocumentService>(),
        ));

    Get.lazyPut(() => HoldingsSearchController(
          searchHoldings: SearchHoldings(Get.find<SearchRepository>()),
          recentsStorage: Get.find<RecentSearchesStorage>(),
        ));

    final authRepo = Get.find<AuthRepository>();
    Get.lazyPut(() => AccountController(
          repository: Get.find<ProfileRepository>(),
          logout: Logout(authRepo),
        ));
  }
}
