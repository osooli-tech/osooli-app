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

  /// Builds the tab only after its first visit, so its controller and API
  /// calls do not fire while the user is still on the home tab.
  Widget _lazy(int index, Widget Function() builder) =>
      controller.visited.contains(index)
          ? builder()
          : const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const DashboardTab(),
            _lazy(1, () => const MapTab()),
            _lazy(2, () => const DeedsTab()),
            _lazy(3, () => const SearchTab()),
            _lazy(4, () => const AccountTab()),
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
