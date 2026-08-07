import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/auth_constants.dart';
import '../controllers/otp_controller.dart';
import '../widgets/auth_header.dart';

class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPin = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: 'otp_title'.tr,
                subtitle: '${'otp_subtitle'.tr} ${controller.phone}',
              ),
              const SizedBox(height: 40),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Pinput(
                    length: AuthConstants.otpLength,
                    autofocus: true,
                    defaultPinTheme: defaultPin,
                    focusedPinTheme: defaultPin.copyWith(
                      decoration: defaultPin.decoration!.copyWith(
                        border:
                            Border.all(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: controller.onOtpChanged,
                    onCompleted: controller.onOtpChanged,
                  ),
                ),
              ),
              Obx(() {
                final error = controller.error.value;
                if (error == null) return const SizedBox(height: 28);
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      error.tr,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.verify,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text('verify'.tr),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.secondsLeft.value > 0) {
                  return Center(
                    child: Text(
                      '${'resend_in'.tr} ${_format(controller.secondsLeft.value)}',
                      style: const TextStyle(color: AppColors.textSoft),
                    ),
                  );
                }
                return Center(
                  child: TextButton(
                    onPressed: controller.resend,
                    child: Text(
                      'resend_code'.tr,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
