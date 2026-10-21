import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../routes/app_pages.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';

class OtpController extends GetxController {
  final VerifyOtp verifyOtp;
  final RequestOtp requestOtp;
  OtpController({required this.verifyOtp, required this.requestOtp});

  late final String phone;
  final isLoading = false.obs;
  final error = RxnString();
  final secondsLeft = 0.obs;

  String _otp = '';
  Timer? _timer;

  bool get canResend => secondsLeft.value == 0;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    phone = args['phone'] as String? ?? '';
    _startCountdown(args['expiresIn'] as int? ?? AuthConstants.defaultOtpExpiry);
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    secondsLeft.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  void onOtpChanged(String value) {
    _otp = value;
    error.value = null;
    if (value.length == AuthConstants.otpLength && !isLoading.value) {
      verify();
    }
  }

  Future<void> verify() async {
    if (_otp.length < AuthConstants.otpLength) {
      error.value = 'otp_invalid';
      return;
    }
    error.value = null;
    isLoading.value = true;
    try {
      await verifyOtp(phone: phone, otp: _otp);
      Get.offAllNamed(Routes.home);
    } on ApiException catch (e) {
      error.value = e.firstError('otp') ?? e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resend() async {
    if (!canResend || isLoading.value) return;
    error.value = null;
    try {
      final expiresIn = await requestOtp(phone);
      _startCountdown(expiresIn);
    } on ApiException catch (e) {
      error.value = e.message;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
