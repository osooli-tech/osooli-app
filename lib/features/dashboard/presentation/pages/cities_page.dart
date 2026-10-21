import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';

/// Cities the owner holds parcels in — from the dashboard by_city breakdown.
/// Tapping a city opens the parcels list filtered to it.
class CitiesPage extends StatelessWidget {
  const CitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final byCity = Get.find<DashboardController>().data.value?.byCity ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'stat_cities'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: byCity.isEmpty
          ? Center(
              child: Text(
                'no_data'.tr,
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textSoft),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: byCity.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final city = byCity[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Get.toNamed(
                      Routes.parcels,
                      arguments: {'city': city.name},
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.fieldFill, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.tealSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_city_outlined,
                                color: AppColors.teal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              city.name,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            '${city.parcelsCount} ${'parcel_count_unit'.tr}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSoft,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_left,
                              size: 20, color: AppColors.textSoft),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
