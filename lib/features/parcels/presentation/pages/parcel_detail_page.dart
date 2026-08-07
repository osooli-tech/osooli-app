import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../../core/constants/map_config.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../../../requests/domain/repositories/requests_repository.dart';
import '../../../requests/domain/usecases/create_request.dart';
import '../../../requests/presentation/widgets/new_request_sheet.dart';
import '../../domain/entities/parcel_detail.dart';
import '../controllers/parcel_detail_controller.dart';
import '../widgets/deed_status_chip.dart';

class ParcelDetailPage extends GetView<ParcelDetailController> {
  const ParcelDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = controller.error.value;
        if (error != null) {
          return SafeArea(
            child: Column(
              children: [
                const Align(
                  alignment: AlignmentDirectional.topStart,
                  child: BackButton(color: AppColors.primary),
                ),
                Expanded(
                  child:
                      AppErrorView(message: error, onRetry: controller.fetch),
                ),
              ],
            ),
          );
        }
        final parcel = controller.parcel.value;
        if (parcel == null) return const SizedBox.shrink();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: AppColors.teal,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                '${'parcel_no_label'.tr} ${parcel.parcelNo}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _ParcelMap(parcel: parcel),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  _MainInfoCard(parcel: parcel),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(
                                color: AppColors.primary, width: 1.4),
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Get.toNamed(Routes.compare),
                          icon: const Icon(Icons.balance_outlined, size: 19),
                          label: Text('compare_short'.tr),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            minimumSize: const Size.fromHeight(48),
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => NewRequestSheet.show(
                            parcel,
                            CreateRequest(Get.find<RequestsRepository>()),
                          ),
                          icon: const Icon(Icons.edit_note, size: 20),
                          label: Text('request_modification'.tr),
                        ),
                      ),
                    ],
                  ),
                  if (parcel.owners.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'owners_title'.tr,
                      icon: Icons.group_outlined,
                      child: Column(
                        children: [
                          for (final owner in parcel.owners)
                            _KeyValueRow(
                              label: owner.name,
                              value: owner.ownershipShare ?? '',
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (parcel.deeds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'deeds_title'.tr,
                      icon: Icons.description_outlined,
                      child: Column(
                        children: [
                          for (final deed in parcel.deeds) _DeedRow(deed: deed),
                        ],
                      ),
                    ),
                  ],
                  if (parcel.boundary != null) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'boundary_title'.tr,
                      icon: Icons.crop_free,
                      child: _BoundaryCompass(boundary: parcel.boundary!),
                    ),
                  ],
                  if (parcel.surveyDecision != null) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'survey_decision_title'.tr,
                      icon: Icons.edit_note,
                      child: Column(
                        children: [
                          if (parcel.surveyDecision!.qrarNo != null)
                            _KeyValueRow(
                                label: 'qrar_no'.tr,
                                value: parcel.surveyDecision!.qrarNo!),
                          if (parcel.surveyDecision!.reportNo != null)
                            _KeyValueRow(
                                label: 'report_no'.tr,
                                value: parcel.surveyDecision!.reportNo!),
                          if (parcel.surveyDecision!.source != null)
                            _KeyValueRow(
                                label: 'qrar_source'.tr,
                                value: parcel.surveyDecision!.source!),
                          if (parcel.surveyDecision!.folder != null)
                            _KeyValueRow(
                                label: 'qrar_folder'.tr,
                                value: parcel.surveyDecision!.folder!),
                        ],
                      ),
                    ),
                  ],
                  if (parcel.documents.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Section(
                      title: 'documents_title'.tr,
                      icon: Icons.folder_open_outlined,
                      child: Column(
                        children: [
                          for (final doc in parcel.documents)
                            _DocumentRow(document: doc),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ParcelMap extends StatelessWidget {
  final ParcelDetail parcel;
  const _ParcelMap({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final points = <ll.LatLng>[
      for (final ring in parcel.polygons) ...ring,
      if (parcel.polygons.isEmpty && parcel.centroid != null) parcel.centroid!,
    ];
    if (points.isEmpty) {
      return Container(
        color: AppColors.teal,
        alignment: Alignment.center,
        child: const Icon(Icons.map_outlined, color: Colors.white54, size: 56),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.fromLTRB(40, 90, 40, 40),
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
            for (final ring in parcel.polygons)
              Polygon(
                points: ring,
                color: AppColors.mapGreenFill,
                borderColor: AppColors.mapGreen,
                borderStrokeWidth: 3.5,
              ),
          ],
        ),
        if (parcel.polygons.isEmpty && parcel.centroid != null)
          MarkerLayer(
            markers: [
              Marker(
                point: parcel.centroid!,
                child: const Icon(Icons.location_on,
                    color: AppColors.mapGreen, size: 36),
              ),
            ],
          ),
      ],
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  final ParcelDetail parcel;
  const _MainInfoCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'parcel_info_title'.tr,
      icon: Icons.info_outline,
      trailing: DeedStatusChip(status: parcel.deedStatus),
      child: Column(
        children: [
          _KeyValueRow(
              label: 'compare_asset_type'.tr, value: parcel.assetType ?? '—'),
          _KeyValueRow(
            label: 'compare_area'.tr,
            value: parcel.areaSqm == null
                ? '—'
                : '${parcel.areaSqm!.toStringAsFixed(0)} م²',
          ),
          _KeyValueRow(
            label: 'compare_location'.tr,
            value: [
              if (parcel.district != null) parcel.district!,
              if (parcel.city != null) parcel.city!,
            ].join('، '),
          ),
          _KeyValueRow(
              label: 'compare_plan_no'.tr, value: parcel.planNo ?? '—'),
          if (parcel.geoId != null)
            _KeyValueRow(label: 'geo_id'.tr, value: parcel.geoId!),
          if (parcel.landTransaction != null)
            _KeyValueRow(
                label: 'land_transaction'.tr, value: parcel.landTransaction!),
          if (parcel.allocationMethod != null)
            _KeyValueRow(
                label: 'allocation_method'.tr,
                value: parcel.allocationMethod!),
          if (parcel.fallIn != null)
            _KeyValueRow(label: 'fall_in'.tr, value: parcel.fallIn!),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeedRow extends StatelessWidget {
  final ParcelDeed deed;
  const _DeedRow({required this.deed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deed.deedNo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (deed.dateHijri != null) '${deed.dateHijri} هـ',
                    if (deed.areaSqm != null)
                      '${deed.areaSqm!.toStringAsFixed(0)} م²',
                    if (deed.deedClass != null) deed.deedClass!,
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
          DeedStatusChip(status: deed.status),
        ],
      ),
    );
  }
}

class _DocumentRow extends GetView<ParcelDetailController> {
  final ParcelDocument document;
  const _DocumentRow({required this.document});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.opening.contains(document.id);
      return InkWell(
        onTap: busy ? null : () => controller.openDocument(document),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  (document.fileType ?? '') == 'pdf'
                      ? Icons.picture_as_pdf_outlined
                      : Icons.image_outlined,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.type ?? 'document'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      (document.fileType ?? '').toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textSoft),
                    ),
                  ],
                ),
              ),
              busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(Icons.download_rounded,
                      color: AppColors.teal, size: 22),
            ],
          ),
        ),
      );
    });
  }
}

/// Boundaries laid out like the web dashboard: north on top, west/east at
/// the sides, south at the bottom, with a north-pointing compass in the
/// middle. Lengths render in green under each description.
class _BoundaryCompass extends StatelessWidget {
  final ParcelBoundary boundary;
  const _BoundaryCompass({required this.boundary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child:
              _BoundaryBox(label: 'boundary_north'.tr, side: boundary.north),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child:
                  _BoundaryBox(label: 'boundary_west'.tr, side: boundary.west),
            ),
            const SizedBox(width: 8),
            const _NorthCompass(),
            const SizedBox(width: 8),
            Expanded(
              child:
                  _BoundaryBox(label: 'boundary_east'.tr, side: boundary.east),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child:
              _BoundaryBox(label: 'boundary_south'.tr, side: boundary.south),
        ),
        if (boundary.engineeringOffice != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.fieldFill),
          const SizedBox(height: 10),
          _KeyValueRow(
            label: 'engineering_office'.tr,
            value: boundary.engineeringOffice!,
          ),
        ],
      ],
    );
  }
}

class _NorthCompass extends StatelessWidget {
  const _NorthCompass();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.navigation, color: AppColors.teal, size: 26),
        const SizedBox(height: 2),
        Text(
          'north_letter'.tr,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          ),
        ),
      ],
    );
  }
}

class _BoundaryBox extends StatelessWidget {
  final String label;
  final BoundarySide? side;
  const _BoundaryBox({required this.label, required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.blueLabel,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            side?.description ?? '—',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (side?.lengthM != null) ...[
            const SizedBox(height: 3),
            Text(
              '${side!.lengthM!.toStringAsFixed(2)} م',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
