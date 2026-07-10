import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import '../core/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password, String role);
  Future<UserModel> signup(String name, String email, String password, String role, String phone);
  Future<UserModel> updateProfile({String? name, String? phone});
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<void> logout();
  Future<void> refreshToken();
}

class PostgresAuthRepository implements AuthRepository {
  final Dio _dio;

  PostgresAuthRepository() : _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return null;

    try {
      final res = await _dio.get(
        '/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        final profile = res.data['data'];
        return UserModel.fromJson(profile as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<UserModel> login(String email, String password, String role) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'username': email,
        'password': password,
      });

      final data = res.data;
      if (res.statusCode != 200) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['data']['accessToken']);
      await prefs.setString('refresh_token', data['data']['refreshToken']);

      final profile = data['data']['user'];
      return UserModel(
        id: profile['id'],
        name: profile['name'],
        email: profile['email'],
        role: profile['role'] ?? role,
        phone: profile['phone'] as String?,
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception(message ?? 'Connection failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please ensure the backend server is running.');
    }
  }

  @override
  Future<UserModel> signup(String name, String email, String password, String role, String phone) async {
    try {
      final parts = name.split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      String endpoint;
      Map<String, dynamic> body;

      switch (role.toLowerCase()) {
        case 'farmer':
          endpoint = '/auth/register/farmer';
          body = {
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
            'farmName': '',
            'farmAddress': '',
            'governmentId': '',
            'bankAccountDetails': '',
          };
          break;
        case 'delivery partner':
          endpoint = '/auth/register/delivery';
          body = {
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'phone': phone,
            'password': password,
            'drivingLicenseNumber': '',
            'vehicleType': '',
            'vehicleNumber': '',
          };
          break;
        default:
          endpoint = '/auth/register/customer';
          body = {
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'phone': phone,
            'password': password,
            'confirmPassword': password,
          };
      }

      final res = await _dio.post(endpoint, data: body);

      if (res.statusCode != 201) {
        throw Exception(res.data['message'] ?? 'Signup failed');
      }

      return login(email, password, role);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception(message ?? 'Connection failed');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please ensure the backend server is running.');
    }
  }

  @override
  Future<UserModel> updateProfile({String? name, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('Not authenticated');

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;

      final res = await _dio.patch('/users/profile',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (res.statusCode == 200 && res.data['success'] == true) {
        final profile = res.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(profile);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? e.message ?? 'Failed to update profile');
    }
  }

  @override
  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('Not authenticated');

    try {
      final res = await _dio.post('/users/change-password',
          data: {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (res.statusCode != 200) {
        throw Exception(
            res.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to change password');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    final accessToken = prefs.getString('access_token');

    if (accessToken != null && refreshToken != null) {
      try {
        await _dio.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      } catch (_) {}
    }

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  @override
  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return;

    try {
      final res = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        if (data['accessToken'] != null) {
          await prefs.setString('access_token', data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await prefs.setString('refresh_token', data['refreshToken']);
        }
      }
    } catch (_) {
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    }
  }
}
