import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'logout'.tr,
              onPressed:
                  controller.isSigningOut.value ? null : controller.signOut,
              icon: const Icon(Icons.logout, color: AppColors.error),
            ),
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          final owner = controller.owner.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_work_outlined,
                  size: 72, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                '${'home_welcome'.tr}${owner == null ? '' : '، ${owner.name}'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
