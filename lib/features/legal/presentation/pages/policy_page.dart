import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../legal_content.dart';

/// Renders either the privacy policy or the terms of use, depending on the
/// route argument {'type': 'privacy' | 'terms'}.
class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final isPrivacy = args['type'] != 'terms';
    final sections = isPrivacy ? LegalContent.privacy : LegalContent.terms;
    final title = isPrivacy ? 'privacy_policy'.tr : 'terms_of_use'.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Text(
              '${'last_updated'.tr}: ${LegalContent.lastUpdated}',
              style:
                  const TextStyle(fontSize: 12.5, color: AppColors.textSoft),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in sections) ...[
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              section.body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: AppColors.textSoft,
              ),
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
