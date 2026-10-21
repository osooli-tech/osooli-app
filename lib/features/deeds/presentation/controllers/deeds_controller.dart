import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/document_service.dart';
import '../../domain/entities/deed_item.dart';
import '../../domain/usecases/get_deeds.dart';

class DeedsController extends GetxController {
  final GetDeeds getDeeds;
  final DocumentService documentService;
  DeedsController({required this.getDeeds, required this.documentService});

  final items = <DeedItem>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();
  final total = 0.obs;

  /// API values: all / active (محدث) / expired (قديم).
  final statusFilter = 'all'.obs;
  final searchQuery = ''.obs;

  /// Documents currently downloading, by document id.
  final opening = <int>{}.obs;

  int _page = 1;
  bool _hasMore = false;
  Timer? _debounce;

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
      final page = await getDeeds(
        page: _page,
        status: statusFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      items.assignAll(page.items);
      total.value = page.total;
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
      final page = await getDeeds(
        page: _page + 1,
        status: statusFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      _page++;
      items.addAll(page.items);
      _hasMore = page.hasMore;
    } on ApiException {
      // Silent: scrolling again retries.
    } finally {
      isLoadingMore.value = false;
    }
  }

  void setStatusFilter(String status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    fetch();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), fetch);
  }

  Future<void> openDocument(DeedItem deed) async {
    final id = deed.documentId;
    if (id == null || opening.contains(id)) return;
    opening.add(id);
    try {
      await documentService.openDocument(documentId: id);
    } on ApiException catch (e) {
      Get.snackbar('documents_title'.tr, e.message.tr,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('documents_title'.tr, 'error_server'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      opening.remove(id);
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
