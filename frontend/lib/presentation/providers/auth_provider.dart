import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/local_db/database_helper.dart';
import 'api_client_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

class AuthNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    return null;
  }

  Future<void> loadSession() async {
    try {
      final dbUser = await DatabaseHelper.instance.getUser();
      if (dbUser != null) {
        state = UserEntity(
          id: dbUser['id'],
          email: dbUser['email'],
          name: dbUser['name'],
          phone: dbUser['phone'],
          role: dbUser['role'] == 'staff' ? UserRole.staff : UserRole.patient,
          createdAt: DateTime.parse(dbUser['created_at']),
        );
      }
    } catch (e) {
      print('Error loading session from DB: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.login(email, password);
    if (user != null) {
      state = user;
      await DatabaseHelper.instance.saveUser({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'role': user.role.name,
        'created_at': user.createdAt.toIso8601String(),
      });
      return true;
    }
    return false;
  }

  Future<String?> register(String email, String password, String name, String phone) async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.register(email, password, name, phone);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await DatabaseHelper.instance.clearUser();
    state = null;
  }

  void updateUser(UserEntity updatedUser) {
    state = updatedUser;
    DatabaseHelper.instance.saveUser({
      'id': updatedUser.id,
      'email': updatedUser.email,
      'name': updatedUser.name,
      'phone': updatedUser.phone,
      'role': updatedUser.role.name,
      'created_at': updatedUser.createdAt.toIso8601String(),
    });
  }

  Future<bool> googleSignIn() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.nativeGoogleSignIn();
    if (user != null) {
      state = user;
      await DatabaseHelper.instance.saveUser({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'role': user.role.name,
        'created_at': user.createdAt.toIso8601String(),
      });
      return true;
    }
    return false;
  }

  Future<String?> resetPassword(String email) async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.resetPasswordForEmail(email);
  }

  Future<String?> updatePassword(String newPassword) async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.updatePassword(newPassword);
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserEntity?>(() {
  return AuthNotifier();
});
