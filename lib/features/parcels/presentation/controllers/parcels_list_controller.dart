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
