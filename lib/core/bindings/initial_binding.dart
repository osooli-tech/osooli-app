import 'package:get/get.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/parcels/data/repositories/parcels_repository_impl.dart';
import '../../features/parcels/domain/repositories/parcels_repository.dart';
import '../../routes/app_pages.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = TokenStorage();
    Get.put(storage, permanent: true);
    Get.put(
      ApiClient(
        tokenStorage: storage,
        onUnauthorized: () {
          storage.clear();
          Get.offAllNamed(Routes.login);
        },
      ),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        remote: AuthRemoteDataSource(Get.find<ApiClient>()),
        storage: storage,
      ),
      permanent: true,
    );
    Get.put<DashboardRepository>(
      DashboardRepositoryImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<ParcelsRepository>(
      ParcelsRepositoryImpl(Get.find<ApiClient>()),
      permanent: true,
    );
  }
}
