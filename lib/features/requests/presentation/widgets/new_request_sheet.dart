import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../parcels/domain/entities/parcel_detail.dart';
import '../../domain/entities/modification_request.dart';
import '../../domain/usecases/create_request.dart';

/// Bottom sheet raising a modification request for one parcel.
class NewRequestSheet extends StatefulWidget {
  final ParcelDetail parcel;
  final CreateRequest createRequest;

  const NewRequestSheet({
    super.key,
    required this.parcel,
    required this.createRequest,
  });

  static void show(ParcelDetail parcel, CreateRequest createRequest) {
    Get.bottomSheet(
      NewRequestSheet(parcel: parcel, createRequest: createRequest),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      isScrollControlled: true,
    );
  }

  @override
  State<NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends State<NewRequestSheet> {
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  String? _fieldName;
  String? _error;
  bool _saving = false;

  /// Current value of the selected field on this parcel, shown for context.
  String? get _currentValue {
    switch (_fieldName) {
      case 'asset_type':
        return widget.parcel.assetType;
      case 'land_transaction':
        return widget.parcel.landTransaction;
      case 'allocation_method':
        return widget.parcel.allocationMethod;
      case 'fall_in':
        return widget.parcel.fallIn;
      case 'deed_status':
        return widget.parcel.deedStatus;
      default:
        return null;
    }
  }

  Future<void> _submit() async {
    final field = _fieldName;
    final value = _valueController.text.trim();
    if (field == null || value.isEmpty) {
      setState(() => _error = 'request_fill_required'.tr);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await widget.createRequest(
        parcelId: widget.parcel.id,
        fieldName: field,
        newValue: value,
        notes: _notesController.text.trim(),
      );
      Get.back();
      Get.snackbar('my_requests'.tr, 'request_created'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (e) {
      setState(() => _error =
          e.firstError('new_value') ?? e.firstError('parcel_id') ?? e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${'new_request_title'.tr} — ${'parcel_no_label'.tr} ${widget.parcel.parcelNo}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _fieldName,
            isExpanded: true,
            decoration: InputDecoration(labelText: 'request_field'.tr),
            items: [
              for (final field in EditableField.all)
                DropdownMenuItem(
                  value: field.name,
                  child: Text(field.labelKey.tr,
                      style: const TextStyle(fontSize: 14)),
                ),
            ],
            onChanged: (value) => setState(() => _fieldName = value),
          ),
          if (_currentValue != null) ...[
            const SizedBox(height: 8),
            Text(
              '${'old_value'.tr}: $_currentValue',
              style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _valueController,
            decoration: InputDecoration(labelText: 'new_value'.tr),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(labelText: 'notes_label'.tr),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!.tr,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text('send_request'.tr),
          ),
        ],
      ),
    );
  }
}
