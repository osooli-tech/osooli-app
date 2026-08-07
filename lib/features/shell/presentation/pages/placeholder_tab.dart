import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';

class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 56, color: AppColors.textSoft),
          const SizedBox(height: 16),
          Text(
            'coming_soon'.tr,
            style: const TextStyle(fontSize: 16, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}
