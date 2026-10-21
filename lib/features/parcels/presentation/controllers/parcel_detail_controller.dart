import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/document_service.dart';
import '../../domain/entities/parcel_detail.dart';
import '../../domain/usecases/get_parcel_detail.dart';

class ParcelDetailController extends GetxController {
  final GetParcelDetail getParcelDetail;
  final DocumentService documentService;
  ParcelDetailController(this.getParcelDetail, this.documentService);

  final isLoading = true.obs;
  final error = RxnString();
  final parcel = Rxn<ParcelDetail>();

  /// Documents currently downloading, by document id.
  final opening = <int>{}.obs;

  late final int parcelId;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    parcelId = (args['id'] as int?) ?? 0;
    fetch();
  }

  Future<void> fetch() async {
    error.value = null;
    isLoading.value = true;
    try {
      parcel.value = await getParcelDetail(parcelId);
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
