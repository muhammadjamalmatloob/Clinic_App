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
}
