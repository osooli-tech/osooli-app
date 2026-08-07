import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/parcel_aggregates_controller.dart';

class SurveyDecisionsPage extends GetView<ParcelAggregatesController> {
  const SurveyDecisionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'stat_survey_decisions'.tr,
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = controller.error.value;
        if (error != null) {
          return AppErrorView(message: error, onRetry: controller.fetch);
        }
        final decisions = controller.withSurveyDecision;
        if (decisions.isEmpty) {
          return Center(
            child: Text(
              'no_data'.tr,
              style: const TextStyle(fontSize: 15, color: AppColors.textSoft),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: decisions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final parcel = decisions[index];
            final decision = parcel.surveyDecision!;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Get.toNamed(
                  Routes.parcelDetail,
                  arguments: {'id': parcel.id},
                ),
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.goldSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit_note,
                                color: AppColors.gold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${'parcel_no_label'.tr} ${parcel.parcelNo}'
                              '${parcel.district == null ? '' : ' · ${parcel.district}'}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_left,
                              size: 20, color: AppColors.textSoft),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        [
                          if (decision.qrarNo != null)
                            '${'qrar_no'.tr}: ${decision.qrarNo}',
                          if (decision.reportNo != null)
                            '${'report_no'.tr}: ${decision.reportNo}',
                          if (decision.source != null)
                            '${'qrar_source'.tr}: ${decision.source}',
                          if (decision.folder != null)
                            '${'qrar_folder'.tr}: ${decision.folder}',
                        ].join(' · '),
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSoft),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
