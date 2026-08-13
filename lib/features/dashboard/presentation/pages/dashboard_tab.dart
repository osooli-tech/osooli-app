import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../../../deeds/presentation/controllers/deeds_controller.dart';
import '../../../shell/presentation/controllers/shell_controller.dart';
import '../../../../core/widgets/simple_bar_chart.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/dashboard_data.dart';
import '../controllers/dashboard_controller.dart';

class DashboardTab extends GetView<DashboardController> {
  const DashboardTab({super.key});

  /// Jumps to the deeds tab with the given API status filter applied.
  void _openDeeds(String status) {
    Get.find<DeedsController>().setStatusFilter(status);
    Get.find<ShellController>().changeTab(2);
  }

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
            if (data.portfolio.totalValue != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _PortfolioCard(portfolio: data.portfolio),
                ),
              ),
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
                    onTap: () => _openDeeds('active'),
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
                    onTap: () => Get.toNamed(Routes.surveyDecisions),
                  ),
                  StatCard(
                    label: 'stat_deeds_expired'.tr,
                    value: '${data.stats.deedsExpired}',
                    icon: Icons.history_toggle_off,
                    color: AppColors.error,
                    onTap: () => _openDeeds('expired'),
                  ),
                  StatCard(
                    label: 'stat_without_deed'.tr,
                    value: '${data.stats.parcelsWithoutDeed}',
                    icon: Icons.article_outlined,
                    color: AppColors.gold,
                    onTap: () => Get.toNamed(
                      Routes.parcels,
                      arguments: {'status': 'none'},
                    ),
                  ),
                  StatCard(
                    label: 'stat_cities'.tr,
                    value: '${data.stats.citiesCount}',
                    icon: Icons.location_city_outlined,
                    onTap: () => Get.toNamed(Routes.cities),
                  ),
                  StatCard(
                    label: 'stat_documents'.tr,
                    value: '${data.stats.documentsCount}',
                    icon: Icons.folder_open_outlined,
                    color: AppColors.accent,
                    onTap: () => Get.toNamed(Routes.documents),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'quick_access'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.holiday_village_outlined,
                          label: 'nav_parcels'.tr,
                          onTap: () => Get.toNamed(Routes.parcels),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.balance_outlined,
                          label: 'compare_title'.tr,
                          onTap: () => Get.toNamed(Routes.compare),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.edit_note,
                          label: 'my_requests'.tr,
                          onTap: () => Get.toNamed(Routes.requests),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  if (data.byRegion.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SimpleBarChart(
                      title: 'by_region_title'.tr,
                      entries: [
                        for (final row in data.byRegion)
                          BarChartEntry(row.name, row.parcelsCount),
                      ],
                      barColor: AppColors.teal,
                    ),
                  ],
                  if (data.byOwner.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SimpleBarChart(
                      title: 'by_owner_title'.tr,
                      entries: [
                        for (final row in data.byOwner)
                          BarChartEntry(row.name, row.parcelsCount),
                      ],
                      barColor: AppColors.accent,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.fieldFill, width: 1.2),
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.tealSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.teal, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

/// Headline card with the estimated value of the owner's priced holdings.
/// Only rendered when at least one parcel carries a price.
class _PortfolioCard extends StatelessWidget {
  final PortfolioSummary portfolio;
  const _PortfolioCard({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final avg = portfolio.avgMPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.teal],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'portfolio_value_title'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: formatMoney(portfolio.totalValue ?? 0),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: ' ${'sar'.tr}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'portfolio_based_on'.trParams({
              'priced': '${portfolio.pricedParcels}',
              'total': '${portfolio.totalParcels}',
            }),
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          if (avg != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${'portfolio_avg_m_price'.tr}: ${formatMoney(avg)} ${'sar_per_sqm'.tr}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
