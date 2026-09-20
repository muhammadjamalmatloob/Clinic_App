import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';

class AuthNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    return null;
  }

  Future<bool> login(String email, String password) async {
    // Hardcoded credentials for mock auth
    if (email == 'user@gmail.com' && password == 'user') {
      state = UserEntity(
        id: 'patient_1',
        name: 'Patient User',
        phoneNumber: '1234567890',
        role: UserRole.patient,
      );
      return true;
    } else if (email == 'admin@gmail.com' && password == 'admin') {
      state = UserEntity(
        id: 'admin_1',
        name: 'Clinic Admin',
        phoneNumber: '0000000000',
        role: UserRole.staff,
      );
      return true;
    }
    return false;
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserEntity?>(() {
  return AuthNotifier();
});
