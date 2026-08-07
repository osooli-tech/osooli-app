import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/storage/recent_searches_storage.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_holdings.dart';

class HoldingsSearchController extends GetxController {
  final SearchHoldings searchHoldings;
  final RecentSearchesStorage recentsStorage;
  HoldingsSearchController({
    required this.searchHoldings,
    required this.recentsStorage,
  });

  /// API axes, in the order the tabs render.
  static const types = ['deed', 'parcel', 'plan', 'owner'];

  final textController = TextEditingController();
  final selectedType = 'deed'.obs;
  final query = ''.obs;
  final results = <SearchResult>[].obs;
  final recents = <String>[].obs;
  final isSearching = false.obs;
  final error = RxnString();

  Timer? _debounce;
  int _requestSeq = 0;

  @override
  void onInit() {
    super.onInit();
    recentsStorage.load().then(recents.assignAll);
  }

  void setType(String type) {
    if (selectedType.value == type) return;
    selectedType.value = type;
    if (query.value.isNotEmpty) _search();
  }

  void onQueryChanged(String value) {
    query.value = value.trim();
    _debounce?.cancel();
    if (query.value.isEmpty) {
      results.clear();
      error.value = null;
      isSearching.value = false;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), _search);
  }

  void searchRecent(String term) {
    textController.text = term;
    query.value = term;
    _search();
  }

  Future<void> _search() async {
    final term = query.value;
    if (term.isEmpty) return;
    final seq = ++_requestSeq;
    error.value = null;
    isSearching.value = true;
    try {
      final hits =
          await searchHoldings(query: term, type: selectedType.value);
      if (seq != _requestSeq) return; // A newer search superseded this one.
      results.assignAll(hits);
      recentsStorage.add(term).then(recents.assignAll);
    } on ApiException catch (e) {
      if (seq == _requestSeq) error.value = e.message;
    } finally {
      if (seq == _requestSeq) isSearching.value = false;
    }
  }

  void clearRecents() {
    recents.clear();
    recentsStorage.clear();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    super.onClose();
  }
}
