import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../domain/entities/owner_profile.dart';
import '../controllers/account_controller.dart';
import '../widgets/edit_contact_sheet.dart';

class AccountTab extends GetView<AccountController> {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final error = controller.error.value;
      if (error != null) {
        return AppErrorView(message: error, onRetry: controller.fetch);
      }
      final profile = controller.profile.value;
      if (profile == null) return const SizedBox.shrink();

      return RefreshIndicator(
        onRefresh: controller.fetch,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _Header(profile: profile),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'stat_parcels_total'.tr,
                      value: '${profile.stats.parcelsCount}',
                      icon: Icons.holiday_village_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'deeds_title'.tr,
                      value: '${profile.stats.deedsCount}',
                      icon: Icons.description_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'stat_documents'.tr,
                      value: '${profile.stats.documentsCount}',
                      icon: Icons.folder_open_outlined,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                child: Column(
                  children: [
                    _MenuRow(
                      icon: Icons.edit_outlined,
                      label: 'edit_profile'.tr,
                      onTap: () => EditContactSheet.show(profile),
                    ),
                    const Divider(height: 1, color: AppColors.fieldFill),
                    _MenuRow(
                      icon: Icons.language,
                      label: 'language'.tr,
                      trailingText:
                          Get.locale?.languageCode == 'ar' ? 'العربية' : 'English',
                      onTap: controller.toggleLanguage,
                    ),
                    const Divider(height: 1, color: AppColors.fieldFill),
                    _MenuRow(
                      icon: Icons.help_outline,
                      label: 'help_support'.tr,
                      onTap: () => Get.snackbar(
                        'help_support'.tr,
                        'coming_soon'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.fieldFill),
                    Obx(
                      () => _MenuRow(
                        icon: Icons.logout,
                        label: 'logout'.tr,
                        color: AppColors.error,
                        onTap: controller.isSigningOut.value
                            ? null
                            : controller.signOut,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  final OwnerProfile profile;
  const _Header({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 24, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    profile.phone,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: .8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.trailingText,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: effectiveColor,
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText!,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSoft),
            )
          : Icon(Icons.chevron_left, color: effectiveColor, size: 20),
    );
  }
}
