import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../compare/presentation/pages/compare_tab.dart';
import '../../../dashboard/presentation/pages/dashboard_tab.dart';
import '../../../parcels/presentation/widgets/parcels_list_view.dart';
import '../controllers/shell_controller.dart';
import 'more_tab.dart';

class ShellPage extends GetView<ShellController> {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DashboardTab(),
            ParcelsListView(),
            CompareTab(),
            MoreTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.tealSoft,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: AppColors.teal),
              label: 'nav_home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.holiday_village_outlined),
              selectedIcon:
                  const Icon(Icons.holiday_village, color: AppColors.teal),
              label: 'nav_parcels'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.balance_outlined),
              selectedIcon: const Icon(Icons.balance, color: AppColors.teal),
              label: 'nav_compare'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              selectedIcon:
                  const Icon(Icons.more_horiz, color: AppColors.teal),
              label: 'nav_more'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
