import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../data/models/legal_document_model.dart';
import '../../data/repositories/legal_repository.dart';

class LegalController extends GetxController {
  final LegalRepository repository;
  LegalController(this.repository);

  final isLoading = true.obs;
  final document = Rxn<LegalDocumentModel>();

  /// True when the server was unreachable and the bundled static text is
  /// shown instead.
  final usingFallback = false.obs;

  late final String documentKey;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    documentKey = args['type'] == 'terms' ? 'terms' : 'privacy';
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    usingFallback.value = false;
    try {
      document.value = await repository.getDocument(documentKey);
    } on ApiException {
      // Offline or server issue — the page falls back to the bundled text.
      usingFallback.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
