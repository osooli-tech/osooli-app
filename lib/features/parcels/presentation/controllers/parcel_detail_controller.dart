import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/parcel_detail.dart';
import '../../domain/usecases/get_parcel_detail.dart';

class ParcelDetailController extends GetxController {
  final GetParcelDetail getParcelDetail;
  ParcelDetailController(this.getParcelDetail);

  final isLoading = true.obs;
  final error = RxnString();
  final parcel = Rxn<ParcelDetail>();

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
}
