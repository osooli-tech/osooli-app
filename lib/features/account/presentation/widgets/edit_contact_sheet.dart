import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/owner_profile.dart';
import '../controllers/account_controller.dart';

/// Bottom sheet editing the only fields the API allows: email and whatsapp.
class EditContactSheet extends StatelessWidget {
  final OwnerProfile profile;
  const EditContactSheet({super.key, required this.profile});

  static void show(OwnerProfile profile) {
    Get.bottomSheet(
      EditContactSheet(profile: profile),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountController>();
    final emailController = TextEditingController(text: profile.email ?? '');
    final whatsappController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'edit_profile'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'edit_profile_note'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'email_label'.tr,
              prefixIcon:
                  const Icon(Icons.email_outlined, color: AppColors.textSoft),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: whatsappController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'whatsapp_label'.tr,
              prefixIcon:
                  const Icon(Icons.chat_outlined, color: AppColors.textSoft),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      final saved = await controller.saveContact(
                        email: emailController.text.trim(),
                        whatsapp: whatsappController.text.trim(),
                      );
                      if (saved) Get.back();
                    },
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text('save'.tr),
            ),
          ),
        ],
      ),
    );
  }
}
