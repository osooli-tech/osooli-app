import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../routes/app_pages.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../domain/entities/owner_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class AccountController extends GetxController {
  final ProfileRepository repository;
  final Logout logout;
  AccountController({required this.repository, required this.logout});

  final isLoading = true.obs;
  final error = RxnString();
  final profile = Rxn<OwnerProfile>();
  final isSaving = false.obs;
  final isSigningOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    error.value = null;
    isLoading.value = true;
    try {
      profile.value = await repository.getProfile();
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns true on success so the sheet can close itself.
  Future<bool> saveContact({required String email, required String whatsapp}) async {
    isSaving.value = true;
    try {
      profile.value =
          await repository.updateProfile(email: email, whatsapp: whatsapp);
      return true;
    } on ApiException catch (e) {
      Get.snackbar('edit_profile'.tr, (e.firstError('email') ?? e.message).tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void toggleLanguage() {
    final current = Get.locale?.languageCode ?? 'ar';
    Get.updateLocale(current == 'ar'
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA'));
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
