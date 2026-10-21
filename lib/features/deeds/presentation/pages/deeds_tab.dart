import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../../domain/entities/deed_item.dart';
import '../../../parcels/presentation/widgets/deed_status_chip.dart';
import '../controllers/deeds_controller.dart';

class DeedsTab extends GetView<DeedsController> {
  const DeedsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final error = controller.error.value;
            if (error != null) {
              return AppErrorView(message: error, onRetry: controller.fetch);
            }
            if (controller.items.isEmpty) {
              return Center(
                child: Text(
                  'deeds_empty'.tr,
                  style:
                      const TextStyle(fontSize: 15, color: AppColors.textSoft),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.fetch,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.extentAfter < 300) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: controller.items.length +
                      1 +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(
                        '${controller.total.value} ${'deed_count_unit'.tr}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                    final itemIndex = index - 1;
                    if (itemIndex >= controller.items.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      );
                    }
                    return _DeedCard(deed: controller.items[itemIndex]);
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Header extends GetView<DeedsController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'deeds_registry'.tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: controller.onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'deeds_search_hint'.tr,
              hintStyle:
                  const TextStyle(fontSize: 13.5, color: AppColors.textSoft),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSoft),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.teal, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'filter_all'.tr,
                    selected: controller.statusFilter.value == 'all',
                    onTap: () => controller.setStatusFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'filter_active'.tr,
                    selected: controller.statusFilter.value == 'active',
                    onTap: () => controller.setStatusFilter('active'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'filter_old'.tr,
                    selected: controller.statusFilter.value == 'expired',
                    onTap: () => controller.setStatusFilter('expired'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.teal : Colors.white70,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DeedCard extends GetView<DeedsController> {
  final DeedItem deed;
  const _DeedCard({required this.deed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldFill, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'deed_no_label'.tr} ${deed.deedNo}',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              DeedStatusChip(status: deed.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (deed.planNo != null) '${'plan_label'.tr} ${deed.planNo}',
              if (deed.parcelNo != null)
                '${'parcel_no'.tr} ${deed.parcelNo}',
              if (deed.city != null || deed.district != null)
                [deed.city, deed.district].whereType<String>().join('، '),
            ].join(' · '),
            style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (deed.dateHijri != null)
                '${'deed_date_label'.tr}: ${deed.dateHijri} هـ',
              if (deed.areaSqm != null)
                '${'compare_area'.tr}: ${deed.areaSqm!.toStringAsFixed(0)} م²',
              if (deed.deedClass != null) deed.deedClass!,
            ].join(' · '),
            style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (deed.hasDocument)
                Expanded(
                  child: Obx(() {
                    final busy = controller.opening.contains(deed.documentId);
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        minimumSize: const Size.fromHeight(42),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      onPressed:
                          busy ? null : () => controller.openDocument(deed),
                      icon: busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.remove_red_eye_outlined,
                              size: 18),
                      label: Text('view_deed'.tr),
                    );
                  }),
                ),
              if (deed.hasDocument && deed.parcelId != null)
                const SizedBox(width: 10),
              if (deed.parcelId != null)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      side: const BorderSide(color: AppColors.teal, width: 1.3),
                      foregroundColor: AppColors.teal,
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => Get.toNamed(
                      Routes.parcelDetail,
                      arguments: {'id': deed.parcelId},
                    ),
                    child: Text('view_parcel'.tr),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
