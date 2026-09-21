import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<String?> register(String email, String password, String name, String phone) async {
    try {
      final role = (email.toLowerCase().contains('admin') || email.toLowerCase().contains('staff')) 
          ? 'staff' 
          : 'patient';
          
      await apiClient.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': name,
        'phone_number': phone,
        'role': role,
      });
      return null; // null means success
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          final detail = data['detail'];
          // FastAPI might return a list for validation errors or a string for HTTPExceptions
          if (detail is List && detail.isNotEmpty) {
             return detail[0]['msg'].toString();
          }
          return detail.toString();
        }
      }
      return 'Registration failed: ${e.message}';
    } catch (e) {
      print('Register error: $e');
      return 'An unexpected error occurred.';
    }
  }

  Future<UserEntity?> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          return await getProfile(token);
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<UserEntity?> getProfile(String token) async {
    try {
      final response = await apiClient.dio.get('/auth/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 200) {
        final data = response.data;
        // In backend, /auth/me returns Supabase user object. 
        // We actually need the Profile from /profiles/me.
        // Wait, the backend /auth/me returns Supabase user. The user id is data['id'].
        // Let's fetch the actual profile from our DB.
        final profileResponse = await apiClient.dio.get('/profiles/me', 
          queryParameters: {'profile_id': data['id']},
          options: Options(headers: {'Authorization': 'Bearer $token'})
        );
        
        if (profileResponse.statusCode == 200) {
           return UserEntity.fromJson(profileResponse.data);
        }
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }
}
