import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/parcel_summary.dart';
import 'deed_status_chip.dart';

class ParcelCard extends StatelessWidget {
  final ParcelSummary parcel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ParcelCard({
    super.key,
    required this.parcel,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.fieldFill, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.tealSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.holiday_village_outlined,
                        color: AppColors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'parcel_no_label'.tr} ${parcel.parcelNo}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (parcel.assetType != null) parcel.assetType!,
                            if (parcel.district != null) parcel.district!,
                            if (parcel.city != null) parcel.city!,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DeedStatusChip(status: parcel.deedStatus),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _InfoItem(
                    icon: Icons.square_foot,
                    label: parcel.areaSqm == null
                        ? '—'
                        : '${parcel.areaSqm!.toStringAsFixed(0)} م²',
                  ),
                  _InfoItem(
                    icon: Icons.description_outlined,
                    label: parcel.deedNo ?? 'no_deed'.tr,
                  ),
                  _InfoItem(
                    icon: Icons.map_outlined,
                    label: parcel.planNo == null
                        ? '—'
                        : '${'plan_label'.tr} ${parcel.planNo}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSoft),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
