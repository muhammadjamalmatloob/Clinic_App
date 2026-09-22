import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';
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

  Future<bool> login(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.login(email, password);
    if (user != null) {
      state = user;
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
    state = null;
  }

  Future<bool> googleSignIn() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.nativeGoogleSignIn();
    if (user != null) {
      state = user;
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
