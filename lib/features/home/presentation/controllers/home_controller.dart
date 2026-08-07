import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../auth/domain/entities/owner.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/logout.dart';

class HomeController extends GetxController {
  final AuthRepository repository;
  final Logout logout;
  HomeController({required this.repository, required this.logout});

  final owner = Rxn<Owner>();
  final isSigningOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    repository.savedOwner().then((value) => owner.value = value);
  }

  Future<void> signOut() async {
    if (isSigningOut.value) return;
    isSigningOut.value = true;
    try {
      await logout();
      Get.offAllNamed(Routes.login);
    } finally {
      isSigningOut.value = false;
    }
  }
}
