import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../controllers/parcel_aggregates_controller.dart';

class DocumentsPage extends GetView<ParcelAggregatesController> {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'documents_title'.tr,
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
        final documents = controller.allDocuments;
        if (documents.isEmpty) {
          return Center(
            child: Text(
              'no_data'.tr,
              style: const TextStyle(fontSize: 15, color: AppColors.textSoft),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: documents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = documents[index];
            final document = entry.document;
            return Obx(() {
              final busy = controller.opening.contains(document.id);
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap:
                      busy ? null : () => controller.openDocument(document),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.fieldFill, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.tealSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            (document.fileType ?? '') == 'pdf'
                                ? Icons.picture_as_pdf_outlined
                                : Icons.image_outlined,
                            color: AppColors.teal,
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
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${'parcel_no_label'.tr} ${entry.parcel.parcelNo}'
                                ' · ${(document.fileType ?? '').toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.2),
                              )
                            : const Icon(Icons.download_rounded,
                                color: AppColors.teal, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }
}
