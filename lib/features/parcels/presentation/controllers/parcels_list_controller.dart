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

  int _page = 1;
  bool _hasMore = false;
  Timer? _debounce;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
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
