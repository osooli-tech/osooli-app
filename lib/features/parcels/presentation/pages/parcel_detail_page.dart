import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
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
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.4),
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Get.toNamed(Routes.compare),
                    icon: const Icon(Icons.balance_outlined, size: 20),
                    label: Text('compare_with_other'.tr),
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
                      child: Column(
                        children: [
                          _BoundaryRow(
                              label: 'boundary_north'.tr,
                              side: parcel.boundary!.north),
                          _BoundaryRow(
                              label: 'boundary_south'.tr,
                              side: parcel.boundary!.south),
                          _BoundaryRow(
                              label: 'boundary_east'.tr,
                              side: parcel.boundary!.east),
                          _BoundaryRow(
                              label: 'boundary_west'.tr,
                              side: parcel.boundary!.west),
                          if (parcel.boundary!.engineeringOffice != null)
                            _KeyValueRow(
                              label: 'engineering_office'.tr,
                              value: parcel.boundary!.engineeringOffice!,
                            ),
                        ],
                      ),
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
                            _KeyValueRow(
                              label: doc.type ?? 'document'.tr,
                              value: (doc.fileType ?? '').toUpperCase(),
                            ),
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
    final points = <LatLng>[
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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.osooli.app',
        ),
        PolygonLayer(
          polygons: [
            for (final ring in parcel.polygons)
              Polygon(
                points: ring,
                color: AppColors.teal.withValues(alpha: .35),
                borderColor: AppColors.teal,
                borderStrokeWidth: 3,
              ),
          ],
        ),
        if (parcel.polygons.isEmpty && parcel.centroid != null)
          MarkerLayer(
            markers: [
              Marker(
                point: parcel.centroid!,
                child: const Icon(Icons.location_on,
                    color: AppColors.teal, size: 36),
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

class _BoundaryRow extends StatelessWidget {
  final String label;
  final BoundarySide? side;
  const _BoundaryRow({required this.label, required this.side});

  @override
  Widget build(BuildContext context) {
    if (side == null) return const SizedBox.shrink();
    final length = side!.lengthM;
    return _KeyValueRow(
      label: label,
      value: [
        if (side!.description != null) side!.description!,
        if (length != null) '(${length.toStringAsFixed(0)} م)',
      ].join(' '),
    );
  }
}
