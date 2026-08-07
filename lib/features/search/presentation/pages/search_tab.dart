import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_pages.dart';
import '../../../parcels/presentation/widgets/deed_status_chip.dart';
import '../controllers/search_controller.dart';

class SearchTab extends GetView<HoldingsSearchController> {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: controller.textController,
              onChanged: controller.onQueryChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                hintStyle: const TextStyle(
                    fontSize: 13.5, color: AppColors.textSoft),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSoft),
                filled: true,
                fillColor: AppColors.fieldFill,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _TypeTabs(),
          const Divider(height: 1, color: AppColors.fieldFill),
          Expanded(
            child: Obx(() {
              if (controller.query.value.isEmpty) {
                return _RecentSearches();
              }
              if (controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final error = controller.error.value;
              if (error != null) {
                return Center(
                  child: Text(
                    error.tr,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.error),
                  ),
                );
              }
              if (controller.results.isEmpty) {
                return Center(
                  child: Text(
                    'search_no_results'.tr,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textSoft),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final hit = controller.results[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Get.toNamed(
                        Routes.parcelDetail,
                        arguments: {'id': hit.id},
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.fieldFill, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hit.title,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (hit.subtitle != null &&
                                      hit.subtitle!.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      hit.subtitle!,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            DeedStatusChip(status: hit.badge),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TypeTabs extends GetView<HoldingsSearchController> {
  @override
  Widget build(BuildContext context) {
    final labels = {
      'deed': 'search_type_deed'.tr,
      'parcel': 'search_type_parcel'.tr,
      'plan': 'search_type_plan'.tr,
      'owner': 'search_type_owner'.tr,
    };
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final type in HoldingsSearchController.types)
              InkWell(
                onTap: () => controller.setType(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2.5,
                        color: controller.selectedType.value == type
                            ? AppColors.teal
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[type]!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: controller.selectedType.value == type
                          ? AppColors.primary
                          : AppColors.textSoft,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends GetView<HoldingsSearchController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, size: 56, color: AppColors.textSoft),
              const SizedBox(height: 12),
              Text(
                'search_start_hint'.tr,
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textSoft),
              ),
            ],
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'recent_searches'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.clearRecents,
                child: Text('clear'.tr,
                    style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          for (final term in controller.recents)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.history,
                  size: 20, color: AppColors.textSoft),
              title: Text(
                term,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.primary),
              ),
              onTap: () => controller.searchRecent(term),
            ),
        ],
      );
    });
  }
}
