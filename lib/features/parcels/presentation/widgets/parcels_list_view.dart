import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/parcels_list_controller.dart';
import 'parcel_card.dart';

/// The parcels list body — reused by the routed page and the shell tab.
class ParcelsListView extends GetView<ParcelsListController> {
  /// Shown when opened as a routed page (from the dashboard stat card).
  final bool showBack;

  const ParcelsListView({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(showBack: showBack),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final error = controller.error.value;
            if (error != null) {
              return AppErrorView(message: error, onRetry: controller.fetch);
            }
            final parcels = controller.filtered;
            if (parcels.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.holiday_village_outlined,
                        size: 56, color: AppColors.textSoft),
                    const SizedBox(height: 12),
                    Text(
                      'parcels_empty'.tr,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textSoft),
                    ),
                  ],
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
                  itemCount: parcels.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= parcels.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      );
                    }
                    final parcel = parcels[index];
                    final selecting = controller.selectionMode.value;
                    final isSelected =
                        controller.selectedIds.contains(parcel.id);
                    return Stack(
                      children: [
                        ParcelCard(
                          parcel: parcel,
                          onTap: selecting
                              ? () => controller.toggleSelected(parcel.id)
                              : () => Get.toNamed(
                                    Routes.parcelDetail,
                                    arguments: {'id': parcel.id},
                                  ),
                          onLongPress: selecting
                              ? null
                              : () => controller.startSelection(parcel.id),
                        ),
                        if (selecting)
                          PositionedDirectional(
                            top: 10,
                            start: 10,
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 22,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textSoft,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
        ),
        Obx(() {
          if (!controller.selectionMode.value) return const SizedBox.shrink();
          return _SelectionTotalsBar(controller: controller);
        }),
      ],
    );
  }
}

/// Totals for the parcels chosen in multi-select mode.
class _SelectionTotalsBar extends StatelessWidget {
  final ParcelsListController controller;
  const _SelectionTotalsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final count = controller.selectedIds.length;
    final area = controller.selectedAreaSqm;
    final value = controller.selectedValue;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'selection_count'.trParams({'count': '$count'}),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    '${'compare_area'.tr}: ${formatMoney(area)} م²',
                    if (value > 0)
                      '${'parcel_price_label'.tr}: ${formatMoney(value)} ${'sar'.tr}',
                  ].join('   ·   '),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.clearSelection,
            icon: const Icon(Icons.close, color: Colors.white70, size: 22),
            tooltip: 'clear'.tr,
          ),
        ],
      ),
    );
  }
}

/// Dark navy header holding the title, a white rounded search field, and the
/// status filter chips — matching the deeds-registry mockup style.
class _Header extends GetView<ParcelsListController> {
  final bool showBack;
  const _Header({required this.showBack});

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
          Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: Get.back,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              if (showBack) const SizedBox(width: 8),
              Obx(
                () => Text(
                  controller.cityFilter.value == null
                      ? 'nav_parcels'.tr
                      : '${'nav_parcels'.tr} — ${controller.cityFilter.value}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: controller.onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'parcels_search_hint'.tr,
              hintStyle:
                  const TextStyle(fontSize: 13.5, color: AppColors.textSoft),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSoft),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
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
                    selected: controller.statusFilter.value == null,
                    onTap: () => controller.setStatusFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'filter_active'.tr,
                    selected: controller.statusFilter.value == 'محدث',
                    onTap: () => controller.setStatusFilter('محدث'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'filter_old'.tr,
                    selected: controller.statusFilter.value == 'قديم',
                    onTap: () => controller.setStatusFilter('قديم'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'no_deed'.tr,
                    selected: controller.statusFilter.value == 'none',
                    onTap: () => controller.setStatusFilter('none'),
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
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.white,
          ),
        ),
      ),
    );
  }
}
