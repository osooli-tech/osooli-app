import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/widgets/simple_bar_chart.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/dashboard_data.dart';
import '../controllers/dashboard_controller.dart';

class DashboardTab extends GetView<DashboardController> {
  const DashboardTab({super.key});

  String _formatArea(double sqm) {
    if (sqm >= 1000000) {
      return '${(sqm / 1000000).toStringAsFixed(1)}M م²';
    }
    if (sqm >= 1000) {
      return '${(sqm / 1000).toStringAsFixed(1)}K م²';
    }
    return '${sqm.toStringAsFixed(0)} م²';
  }

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
      final data = controller.data.value;
      if (data == null) return const SizedBox.shrink();

      return RefreshIndicator(
        onRefresh: controller.fetch,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(data: data)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.35,
                children: [
                  StatCard(
                    label: 'stat_parcels_total'.tr,
                    value: '${data.stats.parcelsTotal}',
                    icon: Icons.holiday_village_outlined,
                    onTap: () => Get.toNamed(Routes.parcels),
                  ),
                  StatCard(
                    label: 'stat_deeds_active'.tr,
                    value: '${data.stats.deedsActive}',
                    icon: Icons.verified_outlined,
                    color: AppColors.accent,
                  ),
                  StatCard(
                    label: 'stat_total_area'.tr,
                    value: _formatArea(data.stats.areaTotalSqm),
                    icon: Icons.square_foot,
                  ),
                  StatCard(
                    label: 'stat_survey_decisions'.tr,
                    value: '${data.stats.surveyDecisionsTotal}',
                    icon: Icons.edit_note,
                    color: AppColors.gold,
                  ),
                  StatCard(
                    label: 'stat_deeds_expired'.tr,
                    value: '${data.stats.deedsExpired}',
                    icon: Icons.history_toggle_off,
                    color: AppColors.error,
                  ),
                  StatCard(
                    label: 'stat_without_deed'.tr,
                    value: '${data.stats.parcelsWithoutDeed}',
                    icon: Icons.article_outlined,
                    color: AppColors.gold,
                  ),
                  StatCard(
                    label: 'stat_cities'.tr,
                    value: '${data.stats.citiesCount}',
                    icon: Icons.location_city_outlined,
                  ),
                  StatCard(
                    label: 'stat_documents'.tr,
                    value: '${data.stats.documentsCount}',
                    icon: Icons.folder_open_outlined,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  SimpleBarChart(
                    title: 'by_city_title'.tr,
                    entries: [
                      for (final row in data.byCity)
                        BarChartEntry(row.name, row.parcelsCount),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SimpleBarChart(
                    title: 'by_district_title'.tr,
                    entries: [
                      for (final row in data.byDistrict)
                        BarChartEntry(row.name, row.parcelsCount),
                    ],
                    barColor: AppColors.gold,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  final DashboardData data;
  const _Header({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'home_welcome'.tr}، ${data.greetingName} 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'dashboard_title'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: .8),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none,
                    color: Colors.white),
              ),
              if (data.unreadNotifications > 0)
                Positioned(
                  top: -3,
                  left: -3,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${data.unreadNotifications}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
