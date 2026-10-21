import '../../domain/entities/owner.dart';

class OwnerModel extends Owner {
  const OwnerModel({
    required super.id,
    required super.name,
    required super.nationalId,
    required super.phone,
    super.email,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) => OwnerModel(
        id: json['id'] as int,
        name: json['name'] as String,
        nationalId: json['national_id'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'national_id': nationalId,
        'phone': phone,
        'email': email,
      };
}
