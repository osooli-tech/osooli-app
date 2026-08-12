import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/phone_input_formatter.dart';

class _LegalLink extends StatelessWidget {
  final String label;
  final String type;
  const _LegalLink({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.policy, arguments: {'type': type}),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accent,
        ),
      ),
    );
  }
}

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              AuthHeader(
                title: 'login_title'.tr,
                subtitle: 'login_subtitle'.tr,
              ),
              const SizedBox(height: 40),
              Text(
                'phone_label'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+\s\-]')),
                    PhoneInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'phone_hint'.tr,
                    prefixIcon: const Icon(Icons.phone_android,
                        color: AppColors.textSoft),
                  ),
                  onSubmitted: (_) => controller.submit(),
                ),
              ),
              Obx(() {
                final error = controller.error.value;
                if (error == null) return const SizedBox(height: 28);
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    error.tr,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                );
              }),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.submit,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text('send_code'.tr),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'login_consent'.tr,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSoft),
                  ),
                  _LegalLink(label: 'terms_of_use'.tr, type: 'terms'),
                  Text(
                    ' ${'and'.tr} ',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSoft),
                  ),
                  _LegalLink(label: 'privacy_policy'.tr, type: 'privacy'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
