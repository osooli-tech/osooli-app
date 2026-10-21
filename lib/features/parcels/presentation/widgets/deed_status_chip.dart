import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class DeedStatusChip extends StatelessWidget {
  final String? status;
  const DeedStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();
    // Deed status has exactly two values server-side: محدث and قديم.
    final active = status == 'محدث';
    final color = active ? AppColors.accent : AppColors.gold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
