import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';

class AuthNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    return null;
  }

  void loginAsPatient(String name, String phone) {
    state = UserEntity(
      id: 'patient_123',
      name: name,
      phoneNumber: phone,
      role: UserRole.patient,
    );
  }

  void loginAsStaff() {
    state = UserEntity(
      id: 'staff_1',
      name: 'Admin',
      phoneNumber: '0000000000',
      role: UserRole.staff,
    );
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserEntity?>(() {
  return AuthNotifier();
});
