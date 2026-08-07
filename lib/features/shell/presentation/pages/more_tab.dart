import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class MoreTab extends GetView<HomeController> {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final owner = controller.owner.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.tealSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          color: AppColors.teal, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            owner?.name ?? '—',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          if (owner != null) ...[
                            const SizedBox(height: 4),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                owner.phone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSoft,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Obx(
                () => TextButton.icon(
                  onPressed: controller.isSigningOut.value
                      ? null
                      : controller.signOut,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(
                    'logout'.tr,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
