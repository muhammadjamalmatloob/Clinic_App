enum UserRole { patient, staff }

class UserEntity {
  final String id;
  final String name;
  final String phoneNumber;
  final UserRole role;

  UserEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.role = UserRole.patient,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      role: json['role'] == 'staff' ? UserRole.staff : UserRole.patient,
    );
  }
}
