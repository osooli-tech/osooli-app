import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_config.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../../../parcels/domain/entities/map_feature.dart';
import '../../../parcels/presentation/widgets/deed_status_chip.dart';
import '../controllers/map_controller.dart';

class MapTab extends GetView<ParcelsMapController> {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final error = controller.error.value;
      if (error != null) {
        return AppErrorView(message: error, onRetry: controller.fetch);
      }
      final points = controller.allPoints;
      if (points.isEmpty) {
        return Center(
          child: Text(
            'map_empty'.tr,
            style: const TextStyle(fontSize: 15, color: AppColors.textSoft),
          ),
        );
      }

      final selected = controller.selected.value;

      return Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(points),
                padding: const EdgeInsets.all(48),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, point) => controller.onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    controller.layerMode.value == MapLayerMode.satellite
                        ? MapConfig.satelliteTiles
                        : MapConfig.standardTiles,
                userAgentPackageName: 'com.sakuki.app',
              ),
              PolygonLayer(
                polygons: [
                  for (final feature in controller.features)
                    for (final ring in feature.polygons)
                      Polygon(
                        points: ring,
                        color: feature.id == selected?.id
                            ? AppColors.mapGreen.withValues(alpha: .55)
                            : AppColors.mapGreenFill,
                        borderColor: feature.id == selected?.id
                            ? Colors.white
                            : AppColors.mapGreen,
                        borderStrokeWidth:
                            feature.id == selected?.id ? 4 : 2.5,
                      ),
                ],
              ),
            ],
          ),

          // Layer toggle button.
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 12,
            start: 12,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: controller.toggleLayer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    controller.layerMode.value == MapLayerMode.satellite
                        ? Icons.map_outlined
                        : Icons.layers_outlined,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
          ),

          // Selected parcel bottom card.
          if (selected != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _SelectedParcelCard(feature: selected),
            ),
        ],
      );
    });
  }
}

class _SelectedParcelCard extends StatelessWidget {
  final MapFeature feature;
  const _SelectedParcelCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'selected_parcel'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              DeedStatusChip(status: feature.deedStatus),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Item(
                  label: 'parcel_no_label'.tr,
                  value: feature.parcelNo,
                ),
              ),
              Expanded(
                child: _Item(
                  label: 'compare_area'.tr,
                  value: feature.areaSqm == null
                      ? '—'
                      : '${feature.areaSqm!.toStringAsFixed(0)} م²',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _Item(
                  label: 'deed_no_label'.tr,
                  value: feature.deedNo ?? '—',
                ),
              ),
              Expanded(
                child: _Item(
                  label: 'compare_location'.tr,
                  value: feature.district ?? '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: () => Get.toNamed(
                Routes.parcelDetail,
                arguments: {'id': feature.id},
              ),
              child: Text('view_details'.tr,
                  style: const TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;
  const _Item({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
