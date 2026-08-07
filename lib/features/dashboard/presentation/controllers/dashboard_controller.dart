import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/get_dashboard.dart';

class DashboardController extends GetxController {
  final GetDashboard getDashboard;
  DashboardController(this.getDashboard);

  final isLoading = true.obs;
  final error = RxnString();
  final data = Rxn<DashboardData>();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    error.value = null;
    isLoading.value = true;
    try {
      data.value = await getDashboard();
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
