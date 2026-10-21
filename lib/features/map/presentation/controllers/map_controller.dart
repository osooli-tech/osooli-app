import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../parcels/domain/entities/map_feature.dart';
import '../../../parcels/domain/repositories/parcels_repository.dart';

enum MapLayerMode { standard, satellite }

class ParcelsMapController extends GetxController {
  final ParcelsRepository repository;
  ParcelsMapController(this.repository);

  final isLoading = true.obs;
  final error = RxnString();
  final features = <MapFeature>[].obs;
  final selected = Rxn<MapFeature>();
  final layerMode = MapLayerMode.standard.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    error.value = null;
    isLoading.value = true;
    try {
      features.assignAll(await repository.getMapFeatures());
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void onMapTap(LatLng point) {
    for (final feature in features) {
      for (final ring in feature.polygons) {
        if (GeoUtils.pointInPolygon(point, ring)) {
          selected.value = feature;
          return;
        }
      }
    }
    selected.value = null;
  }

  void toggleLayer() {
    layerMode.value = layerMode.value == MapLayerMode.standard
        ? MapLayerMode.satellite
        : MapLayerMode.standard;
  }

  List<LatLng> get allPoints => [
        for (final feature in features)
          for (final ring in feature.polygons) ...ring,
      ];
}
