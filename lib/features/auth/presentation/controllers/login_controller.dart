import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../routes/app_pages.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/validators/phone_validator.dart';

class LoginController extends GetxController {
  final RequestOtp requestOtp;
  LoginController(this.requestOtp);

  final phoneController = TextEditingController();
  final isLoading = false.obs;
  final error = RxnString();

  Future<void> submit() async {
    final phone = PhoneValidator.normalize(phoneController.text);
    if (!PhoneValidator.isValid(phone)) {
      error.value = 'phone_invalid';
      return;
    }
    error.value = null;
    isLoading.value = true;
    try {
      final expiresIn = await requestOtp(phone);
      Get.toNamed(
        Routes.otp,
        arguments: {'phone': phone, 'expiresIn': expiresIn},
      );
    } on ApiException catch (e) {
      error.value = e.firstError('phone') ?? e.message;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
