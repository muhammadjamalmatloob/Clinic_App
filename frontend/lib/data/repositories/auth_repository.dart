import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      throw Exception('Invalid login response');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          throw Exception(data['detail'].toString());
        }
      }
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.unknown) {
        throw Exception('No internet connection');
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Invalid Username or Password');
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

  Future<UserEntity?> updateProfile(String profileId, String name, String phone) async {
    try {
      final response = await apiClient.dio.patch('/profiles/me', 
        queryParameters: {'profile_id': profileId},
        data: {
          'full_name': name,
          'phone_number': phone,
        }
      );
      if (response.statusCode == 200) {
        return UserEntity.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Update profile error: $e');
      return null;
    }
  }

  Future<UserEntity?> nativeGoogleSignIn() async {
    try {
      // Web Client ID from Google Cloud Console
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '77060615579-smoqj80q0hm9pj38s7fagmu4op2fle6l.apps.googleusercontent.com',
      );
      
      // Trigger native sign in flow
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in flow
      
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) return null;

      // Send the idToken to our FastAPI backend
      final response = await apiClient.dio.post('/auth/google', data: {
        'id_token': googleAuth.idToken,
        'provider': 'google',
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          return await getProfile(token);
        }
      }
      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.unknown) {
        throw Exception('No internet connection');
      }
      throw Exception('Google login failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign in canceled or failed');
    }
  }

  Future<String?> resetPasswordForEmail(String email) async {
    try {
      final response = await apiClient.dio.post('/auth/reset-password', data: {
        'email': email,
      });
      if (response.statusCode == 200) {
        return null; // success
      }
      return 'Password reset failed';
    } on DioException catch (e) {
       return e.response?.data?['detail']?.toString() ?? e.message;
    } catch (e) {
      print('Reset password error: $e');
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      final response = await apiClient.dio.post('/auth/update-password', data: {
        'new_password': newPassword,
      });
      if (response.statusCode == 200) {
        return null; // success
      }
      return 'Password update failed';
    } on DioException catch (e) {
       return e.response?.data?['detail']?.toString() ?? e.message;
    } catch (e) {
      print('Update password error: $e');
      return 'An unexpected error occurred.';
    }
  }
}
