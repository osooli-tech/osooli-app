class Owner {
  final int id;
  final String name;
  final String nationalId;
  final String phone;
  final String? email;

  const Owner({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.phone,
    this.email,
  });
}
