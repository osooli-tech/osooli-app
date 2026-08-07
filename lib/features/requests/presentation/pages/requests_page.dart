import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../domain/entities/modification_request.dart';
import '../controllers/requests_controller.dart';

class RequestsPage extends GetView<RequestsController> {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my_requests'.tr,
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
        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note,
                    size: 56, color: AppColors.textSoft),
                const SizedBox(height: 12),
                Text(
                  'requests_empty'.tr,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textSoft),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetch,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 300) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: controller.items.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= controller.items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                return _RequestCard(request: controller.items[index]);
              },
            ),
          ),
        );
      }),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ModificationRequestItem request;
  const _RequestCard({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case 'applied':
        return AppColors.accent;
      case 'rejected':
        return AppColors.error;
      case 'sent_to_arcgis':
        return AppColors.teal;
      default: // pending
        return AppColors.gold;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldFill, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.parcelNo == null
                      ? request.fieldLabel
                      : '${'parcel_no_label'.tr} ${request.parcelNo} · ${request.fieldLabel}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color, width: 1),
                ),
                child: Text(
                  request.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ValueBox(
                  label: 'old_value'.tr,
                  value: request.oldValue ?? '—',
                  color: AppColors.textSoft,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_back,
                    size: 18, color: AppColors.textSoft),
              ),
              Expanded(
                child: _ValueBox(
                  label: 'new_value'.tr,
                  value: request.newValue,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${'notes_label'.tr}: ${request.notes}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _formatDate(request.createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ValueBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: color)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
