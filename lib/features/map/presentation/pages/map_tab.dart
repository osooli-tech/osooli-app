import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_config.dart';
import '../../../../core/utils/money_format.dart';
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
      final ownerColors = _ownerColors(controller.features);

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
                            ? _ownerColor(ownerColors, feature.ownerName)
                                .withValues(alpha: .55)
                            : _ownerColor(ownerColors, feature.ownerName)
                                .withValues(alpha: .30),
                        borderColor: feature.id == selected?.id
                            ? Colors.white
                            : _ownerColor(ownerColors, feature.ownerName),
                        borderStrokeWidth:
                            feature.id == selected?.id ? 4 : 2.5,
                        // Parcel number, drawn when it fits at the current zoom.
                        label: feature.parcelNo,
                        labelPlacementCalculator:
                            const PolygonLabelPlacementCalculator.polylabel(),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 4),
                            Shadow(color: Colors.white, blurRadius: 8),
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ),

          // Per-owner color legend (only when parcels split across owners).
          if (ownerColors.length > 1)
            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 68,
              start: 12,
              child: _OwnerLegend(ownerColors: ownerColors),
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

  /// Stable color per owner name, assigned in order of first appearance.
  static Map<String, Color> _ownerColors(List<MapFeature> features) {
    final colors = <String, Color>{};
    for (final feature in features) {
      final owner = feature.ownerName;
      if (owner == null || colors.containsKey(owner)) continue;
      colors[owner] = _palette[colors.length % _palette.length];
    }
    return colors;
  }

  static Color _ownerColor(Map<String, Color> colors, String? owner) =>
      colors[owner] ?? AppColors.mapGreen;

  static const _palette = [
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFFC49A3C),
    Color(0xFFDB5461),
    Color(0xFF9333EA),
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF14605C),
  ];
}

/// Compact legend mapping owner names to their parcel colors.
class _OwnerLegend extends StatelessWidget {
  final Map<String, Color> ownerColors;
  const _OwnerLegend({required this.ownerColors});

  @override
  Widget build(BuildContext context) {
    final entries = ownerColors.entries.take(6).toList();
    final more = ownerColors.length - entries.length;

    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      entry.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (more > 0)
            Text(
              '+$more',
              style: const TextStyle(fontSize: 11, color: AppColors.textSoft),
            ),
        ],
      ),
    );
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
              Expanded(
                child: _Item(
                  label: 'plan_label'.tr,
                  value: feature.planNo ?? '—',
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
                  value: [
                    if (feature.district != null) feature.district!,
                    if (feature.city != null) feature.city!,
                  ].join('، ').isEmpty
                      ? '—'
                      : [
                          if (feature.district != null) feature.district!,
                          if (feature.city != null) feature.city!,
                        ].join('، '),
                ),
              ),
              Expanded(
                child: _Item(
                  label: 'compare_asset_type'.tr,
                  value: feature.assetType ?? '—',
                ),
              ),
            ],
          ),
          if (feature.ownerName != null || feature.parcelPrice != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (feature.ownerName != null)
                  Expanded(
                    flex: 2,
                    child: _Item(
                      label: 'owners_title'.tr,
                      value: feature.ownerName!,
                    ),
                  ),
                if (feature.parcelPrice != null)
                  Expanded(
                    child: _Item(
                      label: 'parcel_price_label'.tr,
                      value:
                          '${formatMoney(feature.parcelPrice!)} ${'sar'.tr}',
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.2),
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.toNamed(Routes.compare),
                    icon: const Icon(Icons.balance_outlined, size: 16),
                    label: Text('compare_short'.tr),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.toNamed(
                      Routes.parcelDetail,
                      arguments: {'id': feature.id},
                    ),
                    child: Text('view_details'.tr),
                  ),
                ),
              ),
            ],
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
