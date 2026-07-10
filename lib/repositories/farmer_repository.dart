import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer_dashboard_model.dart';
import '../models/inventory_model.dart';
import '../models/earnings_model.dart';
import '../models/withdrawal_model.dart';
import '../models/notification_model.dart';
import '../models/bank_account_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

abstract class FarmerRepository {
  Future<FarmerDashboardModel> getDashboard();
  Future<FarmerStatisticsModel> getStatistics();

  Future<List<InventoryModel>> getInventory({int page = 1, int limit = 20});
  Future<InventoryModel> updateStock(String inventoryId, double quantity);
  Future<InventoryModel> addStock(String inventoryId, double quantity);
  Future<InventoryModel> removeStock(String inventoryId, double quantity);

  Future<EarningsModel> getEarnings();
  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20});

  Future<List<WithdrawalModel>> getWithdrawals({int page = 1, int limit = 20});
  Future<WithdrawalModel> requestWithdrawal(double amount, {String? bankAccountId});
  Future<BankAccountModel> updateBankAccount(BankAccountModel account);

  Future<List<AppNotificationModel>> getNotifications({int page = 1, int limit = 20});
  Future<void> markNotificationRead(String notificationId);
  Future<void> markAllNotificationsRead();

  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? name, String? phone, String? farmName, String? farmAddress});
}

class PostgresFarmerRepository implements FarmerRepository {
  final Dio _dio;

  PostgresFarmerRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<FarmerDashboardModel> getDashboard() async {
    try {
      final res = await _dio.get('/farmer/dashboard', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return FarmerDashboardModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return FarmerDashboardModel();
  }

  @override
  Future<FarmerStatisticsModel> getStatistics() async {
    try {
      final res = await _dio.get('/farmer/statistics', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return FarmerStatisticsModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return FarmerStatisticsModel();
  }

  @override
  Future<List<InventoryModel>> getInventory({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/inventory',
          queryParameters: {'page': page, 'limit': limit},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((e) => InventoryModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<InventoryModel> updateStock(String inventoryId, double quantity) async {
    try {
      final res = await _dio.patch('/inventory/$inventoryId',
          data: {'currentStock': quantity},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return InventoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update stock');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update stock');
    }
  }

  @override
  Future<InventoryModel> addStock(String inventoryId, double quantity) async {
    try {
      final res = await _dio.patch('/inventory/$inventoryId/add',
          data: {'quantity': quantity},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return InventoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to add stock');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to add stock');
    }
  }

  @override
  Future<InventoryModel> removeStock(String inventoryId, double quantity) async {
    try {
      final res = await _dio.patch('/inventory/$inventoryId/remove',
          data: {'quantity': quantity},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return InventoryModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to remove stock');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to remove stock');
    }
  }

  @override
  Future<EarningsModel> getEarnings() async {
    try {
      final res = await _dio.get('/farmer/earnings', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return EarningsModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return EarningsModel();
  }

  @override
  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/farmer/transactions',
          queryParameters: {'page': page, 'limit': limit},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<WithdrawalModel>> getWithdrawals({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/withdrawals',
          queryParameters: {'page': page, 'limit': limit},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((e) => WithdrawalModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<WithdrawalModel> requestWithdrawal(double amount, {String? bankAccountId}) async {
    try {
      final res = await _dio.post('/withdrawals',
          data: {
            'amount': amount,
            if (bankAccountId != null) 'bankAccountId': bankAccountId,
          },
          options: await _authOptions());
      if ((res.statusCode == 201 || res.statusCode == 200) &&
          res.data['success'] == true &&
          res.data['data'] != null) {
        return WithdrawalModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to request withdrawal');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to request withdrawal');
    }
  }

  @override
  Future<BankAccountModel> updateBankAccount(BankAccountModel account) async {
    try {
      final res = await _dio.patch('/bank-account',
          data: account.toJson(),
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return BankAccountModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update bank account');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update bank account');
    }
  }

  @override
  Future<List<AppNotificationModel>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/notifications',
          queryParameters: {'page': page, 'limit': limit},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _dio.patch('/notifications/$notificationId/read', options: await _authOptions());
    } catch (_) {}
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await _dio.patch('/notifications/read', options: await _authOptions());
    } catch (_) {}
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final res = await _dio.get('/farmer/profile', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to load profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to load profile');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? farmName,
    String? farmAddress,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (farmName != null) data['farmName'] = farmName;
      if (farmAddress != null) data['farmAddress'] = farmAddress;

      final res = await _dio.patch('/farmer/profile',
          data: data, options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update profile');
    }
  }
}
