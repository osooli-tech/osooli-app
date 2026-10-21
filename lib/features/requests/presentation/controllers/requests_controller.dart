import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/modification_request.dart';
import '../../domain/usecases/get_requests.dart';

class RequestsController extends GetxController {
  final GetRequests getRequests;
  RequestsController(this.getRequests);

  final items = <ModificationRequestItem>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();

  int _page = 1;
  bool _hasMore = false;

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
      final page = await getRequests(page: _page);
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
      final page = await getRequests(page: _page + 1);
      _page++;
      items.addAll(page.items);
      _hasMore = page.hasMore;
    } on ApiException {
      // Silent: scrolling again retries.
    } finally {
      isLoadingMore.value = false;
    }
  }
}
