import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../core/services/api_client.dart';

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
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  PostgresAuthRepository(this._apiClient);

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final res = await _apiClient.dio.get('/auth/profile');

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
      final res = await _apiClient.dio.post('/auth/login', data: {
        'username': email,
        'password': password,
      });

      final data = res.data;
      if (res.statusCode != 200) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      await _secureStorage.write(key: 'access_token', value: data['data']['accessToken']);
      await _secureStorage.write(key: 'refresh_token', value: data['data']['refreshToken']);

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

      final res = await _apiClient.dio.post(endpoint, data: body);

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
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;

      final res = await _apiClient.dio.patch('/users/profile', data: data);

      if (res.statusCode == 200 && res.data['success'] == true) {
        final profile = res.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(profile);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update profile');
    }
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      final res = await _apiClient.dio.post('/users/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (res.statusCode != 200) {
        throw Exception(res.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to change password');
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');

    if (refreshToken != null) {
      try {
        await _apiClient.dio.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {}
    }

    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    _apiClient.clearPendingRequests();
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return;

    try {
      final res = await _apiClient.dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        if (data['accessToken'] != null) {
          await _secureStorage.write(key: 'access_token', value: data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await _secureStorage.write(key: 'refresh_token', value: data['refreshToken']);
        }
      }
    } catch (_) {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
    }
  }
}