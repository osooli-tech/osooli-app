import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../parcels/domain/entities/parcel_detail.dart';
import '../../../parcels/domain/entities/parcel_summary.dart';
import '../../../parcels/domain/usecases/get_parcel_detail.dart';
import '../../../parcels/domain/usecases/get_parcels.dart';

class CompareController extends GetxController {
  final GetParcels getParcels;
  final GetParcelDetail getParcelDetail;
  CompareController({required this.getParcels, required this.getParcelDetail});

  final isLoadingList = true.obs;
  final listError = RxnString();
  final parcels = <ParcelSummary>[].obs;

  final selectedIdA = RxnInt();
  final selectedIdB = RxnInt();
  final detailA = Rxn<ParcelDetail>();
  final detailB = Rxn<ParcelDetail>();
  final isLoadingDetails = false.obs;
  final detailError = RxnString();

  bool get bothSelected => selectedIdA.value != null && selectedIdB.value != null;

  @override
  void onInit() {
    super.onInit();
    loadParcels();
  }

  Future<void> loadParcels() async {
    listError.value = null;
    isLoadingList.value = true;
    try {
      // per_page capped at 100 server-side; a single owner never exceeds it.
      final page = await getParcels(perPage: 100);
      parcels.assignAll(page.items);
    } on ApiException catch (e) {
      listError.value = e.message;
    } finally {
      isLoadingList.value = false;
    }
  }

  Future<void> selectA(int? id) async {
    selectedIdA.value = id;
    detailA.value = null;
    await _loadDetails();
  }

  Future<void> selectB(int? id) async {
    selectedIdB.value = id;
    detailB.value = null;
    await _loadDetails();
  }

  Future<void> _loadDetails() async {
    if (!bothSelected) return;
    detailError.value = null;
    isLoadingDetails.value = true;
    try {
      final results = await Future.wait([
        getParcelDetail(selectedIdA.value!),
        getParcelDetail(selectedIdB.value!),
      ]);
      detailA.value = results[0];
      detailB.value = results[1];
    } on ApiException catch (e) {
      detailError.value = e.message;
    } finally {
      isLoadingDetails.value = false;
    }
  }
}
