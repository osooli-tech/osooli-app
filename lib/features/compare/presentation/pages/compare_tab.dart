import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_config.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../parcels/domain/entities/parcel_detail.dart';
import '../../../parcels/domain/entities/parcel_summary.dart';
import '../controllers/compare_controller.dart';

class CompareTab extends GetView<CompareController> {
  const CompareTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingList.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final listError = controller.listError.value;
      if (listError != null) {
        return AppErrorView(message: listError, onRetry: controller.loadParcels);
      }
      if (controller.parcels.length < 2) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'compare_needs_two'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textSoft),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ParcelPicker(
                    label: 'parcel_a'.tr,
                    color: AppColors.teal,
                    parcels: controller.parcels,
                    selectedId: controller.selectedIdA.value,
                    excludedId: controller.selectedIdB.value,
                    onChanged: controller.selectA,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ParcelPicker(
                    label: 'parcel_b'.tr,
                    color: AppColors.gold,
                    parcels: controller.parcels,
                    selectedId: controller.selectedIdB.value,
                    excludedId: controller.selectedIdA.value,
                    onChanged: controller.selectB,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.isLoadingDetails.value)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.detailError.value != null)
              AppErrorView(
                message: controller.detailError.value!,
                onRetry: () {
                  controller.selectA(controller.selectedIdA.value);
                },
              )
            else if (controller.detailA.value != null &&
                controller.detailB.value != null) ...[
              _CompareTable(
                a: controller.detailA.value!,
                b: controller.detailB.value!,
              ),
              const SizedBox(height: 16),
              _CompareMap(
                a: controller.detailA.value!,
                b: controller.detailB.value!,
              ),
            ] else
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'compare_hint'.tr,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 15, color: AppColors.textSoft),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ParcelPicker extends StatelessWidget {
  final String label;
  final Color color;
  final List<ParcelSummary> parcels;
  final int? selectedId;
  final int? excludedId;
  final ValueChanged<int?> onChanged;

  const _ParcelPicker({
    required this.label,
    required this.color,
    required this.parcels,
    required this.selectedId,
    required this.excludedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: selectedId,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 1.6),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: Text('select_parcel'.tr, style: const TextStyle(fontSize: 13)),
          items: [
            for (final parcel in parcels)
              if (parcel.id != excludedId)
                DropdownMenuItem(
                  value: parcel.id,
                  child: Text(
                    '${'parcel_no'.tr} ${parcel.parcelNo}'
                    '${parcel.district == null ? '' : ' · ${parcel.district}'}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _CompareTable extends StatelessWidget {
  final ParcelDetail a;
  final ParcelDetail b;
  const _CompareTable({required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    String area(ParcelDetail p) =>
        p.areaSqm == null ? '—' : '${p.areaSqm!.toStringAsFixed(0)} م²';
    String location(ParcelDetail p) => [
          if (p.district != null) p.district!,
          if (p.city != null) p.city!,
        ].join('، ').ifEmpty('—');

    final rows = <(String, String, String)>[
      ('compare_area'.tr, area(a), area(b)),
      ('compare_location'.tr, location(a), location(b)),
      ('compare_deed_status'.tr, a.deedStatus ?? '—', b.deedStatus ?? '—'),
      ('compare_deed_date'.tr, a.deedDateHijri ?? '—', b.deedDateHijri ?? '—'),
      ('compare_plan_no'.tr, a.planNo ?? '—', b.planNo ?? '—'),
      ('compare_asset_type'.tr, a.assetType ?? '—', b.assetType ?? '—'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppColors.fieldFill),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _ValueChip(
                        value: rows[i].$2, color: AppColors.teal),
                  ),
                  SizedBox(
                    width: 96,
                    child: Text(
                      rows[i].$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ValueChip(
                        value: rows[i].$3, color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String value;
  final Color color;
  const _ValueChip({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        border: Border.all(color: color, width: 1.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CompareMap extends StatelessWidget {
  final ParcelDetail a;
  final ParcelDetail b;
  const _CompareMap({required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final allPoints = <ll.LatLng>[
      for (final ring in a.polygons) ...ring,
      for (final ring in b.polygons) ...ring,
      if (a.polygons.isEmpty && a.centroid != null) a.centroid!,
      if (b.polygons.isEmpty && b.centroid != null) b.centroid!,
    ];
    if (allPoints.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'parcels_locations'.tr,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 260,
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints(allPoints),
                  padding: const EdgeInsets.all(36),
                ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: MapConfig.standardTiles,
                  userAgentPackageName: 'com.osooli.app',
                ),
                PolygonLayer(
                  polygons: [
                    for (final ring in a.polygons)
                      Polygon(
                        points: ring,
                        color: AppColors.teal.withValues(alpha: .35),
                        borderColor: AppColors.teal,
                        borderStrokeWidth: 3,
                      ),
                    for (final ring in b.polygons)
                      Polygon(
                        points: ring,
                        color: AppColors.primary.withValues(alpha: .35),
                        borderColor: AppColors.primary,
                        borderStrokeWidth: 3,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (a.polygons.isEmpty && a.centroid != null)
                      Marker(
                        point: a.centroid!,
                        child: const Icon(Icons.location_on,
                            color: AppColors.teal, size: 34),
                      ),
                    if (b.polygons.isEmpty && b.centroid != null)
                      Marker(
                        point: b.centroid!,
                        child: const Icon(Icons.location_on,
                            color: AppColors.primary, size: 34),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
