import 'package:get/get.dart';

class ShellController extends GetxController {
  final currentIndex = 0.obs;

  /// Tabs that have been opened at least once. Unvisited tabs render a
  /// placeholder so their controllers (and API calls) start only on first
  /// open — opening the app fires one request, not five.
  final visited = <int>{0}.obs;

  void changeTab(int index) {
    visited.add(index);
    currentIndex.value = index;
  }
}
