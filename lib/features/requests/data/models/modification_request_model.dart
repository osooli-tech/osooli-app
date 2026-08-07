import '../../domain/entities/modification_request.dart';

class ModificationRequestModel extends ModificationRequestItem {
  const ModificationRequestModel({
    required super.id,
    super.parcelId,
    super.parcelNo,
    required super.fieldName,
    required super.fieldLabel,
    super.oldValue,
    required super.newValue,
    super.notes,
    required super.status,
    required super.statusLabel,
    super.createdAt,
    super.resolvedAt,
  });

  factory ModificationRequestModel.fromJson(Map<String, dynamic> json) {
    final parcel = json['parcel'] as Map<String, dynamic>?;
    return ModificationRequestModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      parcelId: (parcel?['id'] as num?)?.toInt(),
      parcelNo: parcel?['parcel_no']?.toString(),
      fieldName: json['field_name'] as String? ?? '',
      fieldLabel: json['field_label'] as String? ?? '',
      oldValue: json['old_value']?.toString(),
      newValue: json['new_value']?.toString() ?? '',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      resolvedAt: json['resolved_at'] as String?,
    );
  }
}
