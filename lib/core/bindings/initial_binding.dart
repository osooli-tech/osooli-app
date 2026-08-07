import 'package:get/get.dart';

import '../../features/account/data/repositories/profile_repository_impl.dart';
import '../../features/account/domain/repositories/profile_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/deeds/data/repositories/deeds_repository_impl.dart';
import '../../features/deeds/domain/repositories/deeds_repository.dart';
import '../../features/parcels/data/repositories/parcels_repository_impl.dart';
import '../../features/parcels/domain/repositories/parcels_repository.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../routes/app_pages.dart';
import '../network/api_client.dart';
import '../services/document_service.dart';
import '../storage/recent_searches_storage.dart';
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
    Get.put<DeedsRepository>(
      DeedsRepositoryImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<SearchRepository>(
      SearchRepositoryImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<ProfileRepository>(
      ProfileRepositoryImpl(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put(DocumentService(Get.find<ApiClient>()), permanent: true);
    Get.put(RecentSearchesStorage(), permanent: true);
  }
}
