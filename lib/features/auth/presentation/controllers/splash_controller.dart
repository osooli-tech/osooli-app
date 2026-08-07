import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../domain/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository repository;
  SplashController(this.repository);

  @override
  Future<void> onReady() async {
    super.onReady();
    // Brief pause so the logo is visible.
    await Future.delayed(const Duration(milliseconds: 400));
    var hasSession = false;
    try {
      hasSession = await repository.hasSession();
    } catch (_) {
      // Secure storage can fail on some devices; treat as signed out.
    }
    Get.offAllNamed(hasSession ? Routes.home : Routes.onboarding);
  }
}
