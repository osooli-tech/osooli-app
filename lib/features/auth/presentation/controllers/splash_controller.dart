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
    await Future.delayed(const Duration(milliseconds: 900));
    final hasSession = await repository.hasSession();
    Get.offAllNamed(hasSession ? Routes.home : Routes.onboarding);
  }
}
