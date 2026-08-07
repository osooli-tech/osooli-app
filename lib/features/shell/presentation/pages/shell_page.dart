import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../account/presentation/pages/account_tab.dart';
import '../../../dashboard/presentation/pages/dashboard_tab.dart';
import '../../../deeds/presentation/pages/deeds_tab.dart';
import '../../../map/presentation/pages/map_tab.dart';
import '../../../search/presentation/pages/search_tab.dart';
import '../controllers/shell_controller.dart';

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
            MapTab(),
            DeedsTab(),
            SearchTab(),
            AccountTab(),
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
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map, color: AppColors.teal),
              label: 'nav_map'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              selectedIcon:
                  const Icon(Icons.description, color: AppColors.teal),
              label: 'nav_deeds'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search, color: AppColors.teal),
              label: 'nav_search'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person, color: AppColors.teal),
              label: 'nav_account'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
