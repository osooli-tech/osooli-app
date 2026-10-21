class ModificationRequestItem {
  final int id;
  final int? parcelId;
  final String? parcelNo;
  final String fieldName;
  final String fieldLabel;
  final String? oldValue;
  final String newValue;
  final String? notes;
  final String status;
  final String statusLabel;
  final String? createdAt;
  final String? resolvedAt;

  const ModificationRequestItem({
    required this.id,
    this.parcelId,
    this.parcelNo,
    required this.fieldName,
    required this.fieldLabel,
    this.oldValue,
    required this.newValue,
    this.notes,
    required this.status,
    required this.statusLabel,
    this.createdAt,
    this.resolvedAt,
  });
}

/// The six fields the API allows an owner to request changes for
/// (StoreModificationRequest::EDITABLE_FIELDS).
class EditableField {
  final String name;
  final String labelKey;
  const EditableField(this.name, this.labelKey);

  static const all = [
    EditableField('asset_type', 'compare_asset_type'),
    EditableField('land_transaction', 'land_transaction'),
    EditableField('allocation_method', 'allocation_method'),
    EditableField('fall_in', 'fall_in'),
    EditableField('deed_status', 'compare_deed_status'),
    EditableField('deed_class', 'deed_class_label'),
  ];
}
