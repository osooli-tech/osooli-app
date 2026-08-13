import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/parcel_summary.dart';
import '../../domain/usecases/get_parcels.dart';

class ParcelsListController extends GetxController {
  final GetParcels getParcels;
  ParcelsListController(this.getParcels);

  final items = <ParcelSummary>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();
  final searchQuery = ''.obs;

  /// Client-side deed-status filter — null means all, 'none' means parcels
  /// without a deed. The parcels endpoint has no status parameter, so this
  /// filters the loaded list.
  final statusFilter = RxnString();

  /// Server-side city filter, set when opened from the cities page.
  final cityFilter = RxnString();

  List<ParcelSummary> get filtered {
    final status = statusFilter.value;
    if (status == null) return items;
    if (status == 'none') {
      return items.where((p) => p.deedStatus == null).toList();
    }
    return items.where((p) => p.deedStatus == status).toList();
  }

  void setStatusFilter(String? status) => statusFilter.value = status;

  /// Multi-select mode: long-press starts it, taps toggle, and the totals
  /// bar shows combined area/value for the chosen parcels.
  final selectionMode = false.obs;
  final selectedIds = <int>{}.obs;

  void startSelection(int id) {
    selectionMode.value = true;
    selectedIds.add(id);
  }

  void toggleSelected(int id) {
    if (!selectedIds.remove(id)) {
      selectedIds.add(id);
    } else if (selectedIds.isEmpty) {
      selectionMode.value = false;
    }
  }

  void clearSelection() {
    selectedIds.clear();
    selectionMode.value = false;
  }

  List<ParcelSummary> get selectedParcels =>
      items.where((p) => selectedIds.contains(p.id)).toList();

  double get selectedAreaSqm => selectedParcels.fold(
      0.0, (sum, p) => sum + (p.areaSqm ?? 0));

  double get selectedValue => selectedParcels.fold(
      0.0, (sum, p) => sum + (p.parcelPrice ?? 0));

  int _page = 1;
  bool _hasMore = false;
  Timer? _debounce;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    cityFilter.value = args['city'] as String?;
    statusFilter.value = args['status'] as String?;
    fetch();
  }

  Future<void> fetch() async {
    _page = 1;
    error.value = null;
    isLoading.value = true;
    try {
      final page = await getParcels(
        page: _page,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        city: cityFilter.value,
      );
      items.assignAll(page.items);
      _hasMore = page.hasMore;
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final page = await getParcels(
        page: _page + 1,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        city: cityFilter.value,
      );
      _page++;
      items.addAll(page.items);
      _hasMore = page.hasMore;
    } on ApiException {
      // Silent: the user can scroll again to retry.
    } finally {
      isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), fetch);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
