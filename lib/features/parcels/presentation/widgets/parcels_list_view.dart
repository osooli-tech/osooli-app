import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/parcels_list_controller.dart';
import 'parcel_card.dart';

/// The parcels list body — reused by the routed page and the shell tab.
class ParcelsListView extends GetView<ParcelsListController> {
  const ParcelsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: controller.onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'parcels_search_hint'.tr,
              hintStyle:
                  const TextStyle(fontSize: 14, color: AppColors.textSoft),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSoft),
              isDense: true,
            ),
          ),
        ),
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: controller.items.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= controller.items.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      );
                    }
                    final parcel = controller.items[index];
                    return ParcelCard(
                      parcel: parcel,
                      onTap: () => Get.toNamed(
                        Routes.parcelDetail,
                        arguments: {'id': parcel.id},
                      ),
                    );
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
