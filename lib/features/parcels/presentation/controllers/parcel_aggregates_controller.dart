import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/document_service.dart';
import '../../domain/entities/parcel_detail.dart';
import '../../domain/usecases/get_parcel_detail.dart';
import '../../domain/usecases/get_parcels.dart';

/// Loads the details of all the owner's parcels so cross-parcel screens
/// (survey decisions, all documents) can aggregate them. There is no
/// dedicated endpoint for these — an owner holds few parcels, so fetching
/// details client-side is cheap. Capped defensively at [_maxDetails].
class ParcelAggregatesController extends GetxController {
  final GetParcels getParcels;
  final GetParcelDetail getParcelDetail;
  final DocumentService documentService;
  ParcelAggregatesController({
    required this.getParcels,
    required this.getParcelDetail,
    required this.documentService,
  });

  static const _maxDetails = 30;
  static const _chunkSize = 5;

  final isLoading = true.obs;
  final error = RxnString();
  final details = <ParcelDetail>[].obs;
  final truncated = false.obs;
  final opening = <int>{}.obs;

  List<ParcelDetail> get withSurveyDecision =>
      details.where((p) => p.surveyDecision != null).toList();

  List<({ParcelDetail parcel, ParcelDocument document})> get allDocuments => [
        for (final parcel in details)
          for (final document in parcel.documents)
            (parcel: parcel, document: document),
      ];

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    error.value = null;
    isLoading.value = true;
    try {
      final page = await getParcels(perPage: 100);
      final ids = page.items.map((p) => p.id).toList();
      truncated.value = ids.length > _maxDetails;
      final capped = ids.take(_maxDetails).toList();

      final loaded = <ParcelDetail>[];
      for (var i = 0; i < capped.length; i += _chunkSize) {
        final chunk = capped.skip(i).take(_chunkSize);
        loaded.addAll(await Future.wait(chunk.map(getParcelDetail.call)));
      }
      details.assignAll(loaded);
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openDocument(ParcelDocument document) async {
    if (opening.contains(document.id)) return;
    opening.add(document.id);
    try {
      await documentService.openDocument(
        documentId: document.id,
        fileType: document.fileType,
      );
    } on ApiException catch (e) {
      Get.snackbar('documents_title'.tr, e.message.tr,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('documents_title'.tr, 'error_server'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      opening.remove(document.id);
    }
  }
}
