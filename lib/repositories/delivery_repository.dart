import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/delivery_dashboard_model.dart';
import '../models/delivery_model.dart';
import '../models/delivery_profile_model.dart';
import '../models/earnings_model.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';

abstract class DeliveryRepository {
  Future<DeliveryDashboardModel> getDashboard();
  Future<DeliveryStats> getStatistics();

  Future<List<DeliveryOrder>> getDeliveries({
    String? status,
    int page = 1,
    int limit = 20,
  });
  Future<DeliveryOrder> getDelivery(String deliveryId);
  Future<DeliveryOrder> acceptDelivery(String deliveryId);
  Future<DeliveryOrder> rejectDelivery(String deliveryId, {String? reason});
  Future<DeliveryOrder> markPickedUp(String deliveryId);
  Future<DeliveryOrder> startDelivery(String deliveryId);
  Future<DeliveryOrder> verifyOtp(String deliveryId, String otp);
  Future<DeliveryOrder> completeDelivery(String deliveryId);

  Future<void> updateLocation(String deliveryId, double lat, double lng);

  Future<EarningsModel> getEarnings();
  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20});

  Future<DeliveryHistory> getHistory({int page = 1, int limit = 20});

  Future<List<AppNotificationModel>> getNotifications({int page = 1, int limit = 20});
  Future<void> markNotificationRead(String notificationId);
  Future<void> markAllNotificationsRead();

  Future<DeliveryProfile> getProfile();
  Future<DeliveryProfile> updateProfile({
    String? name,
    String? phone,
    String? email,
    DeliveryVehicleInfo? vehicle,
    DeliveryLicenseInfo? license,
    DeliveryBankInfo? bankAccount,
  });
  Future<void> toggleAvailability();
}

class PostgresDeliveryRepository implements DeliveryRepository {
  final Dio _dio;

  PostgresDeliveryRepository()
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
  Future<DeliveryDashboardModel> getDashboard() async {
    try {
      final res = await _dio.get('/delivery/dashboard', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryDashboardModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return DeliveryDashboardModel(
      stats: DeliveryStats.fromJson({}),
      recentEarnings: [],
      unreadNotifications: 0,
    );
  }

  @override
  Future<DeliveryStats> getStatistics() async {
    try {
      final res = await _dio.get('/delivery/statistics', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryStats.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return DeliveryStats.fromJson({});
  }

  @override
  Future<List<DeliveryOrder>> getDeliveries({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) params['status'] = status;

      final res = await _dio.get('/delivery', queryParameters: params, options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((e) => DeliveryOrder.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<DeliveryOrder> getDelivery(String deliveryId) async {
    try {
      final res = await _dio.get('/delivery/$deliveryId', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Delivery not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to load delivery');
    }
  }

  @override
  Future<DeliveryOrder> acceptDelivery(String deliveryId) async {
    try {
      final res = await _dio.patch('/delivery/$deliveryId/accept', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to accept delivery');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to accept delivery');
    }
  }

  @override
  Future<DeliveryOrder> rejectDelivery(String deliveryId, {String? reason}) async {
    try {
      final res = await _dio.patch(
        '/delivery/$deliveryId/reject',
        data: {if (reason != null) 'reason': reason},
        options: await _authOptions(),
      );
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to reject delivery');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to reject delivery');
    }
  }

  @override
  Future<DeliveryOrder> markPickedUp(String deliveryId) async {
    try {
      final res = await _dio.patch('/delivery/$deliveryId/pickup', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to mark pickup');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to mark pickup');
    }
  }

  @override
  Future<DeliveryOrder> startDelivery(String deliveryId) async {
    try {
      final res = await _dio.patch('/delivery/$deliveryId/start', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to start delivery');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to start delivery');
    }
  }

  @override
  Future<DeliveryOrder> verifyOtp(String deliveryId, String otp) async {
    try {
      final res = await _dio.post(
        '/delivery/$deliveryId/verify-otp',
        data: {'otp': otp},
        options: await _authOptions(),
      );
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Invalid OTP');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'OTP verification failed');
    }
  }

  @override
  Future<DeliveryOrder> completeDelivery(String deliveryId) async {
    try {
      final res = await _dio.patch('/delivery/$deliveryId/complete', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to complete delivery');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to complete delivery');
    }
  }

  @override
  Future<void> updateLocation(String deliveryId, double lat, double lng) async {
    try {
      await _dio.patch(
        '/delivery/$deliveryId/location',
        data: {'latitude': lat, 'longitude': lng},
        options: await _authOptions(),
      );
    } catch (_) {}
  }

  @override
  Future<EarningsModel> getEarnings() async {
    try {
      final res = await _dio.get('/delivery/earnings', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return EarningsModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return EarningsModel();
  }

  @override
  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/delivery/transactions',
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
  Future<DeliveryHistory> getHistory({int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/delivery/history',
          queryParameters: {'page': page, 'limit': limit},
          options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryHistory.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return DeliveryHistory(orders: [], total: 0, page: page, limit: limit);
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
  Future<DeliveryProfile> getProfile() async {
    try {
      final res = await _dio.get('/delivery/profile', options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryProfile.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to load profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to load profile');
    }
  }

  @override
  Future<DeliveryProfile> updateProfile({
    String? name,
    String? phone,
    String? email,
    DeliveryVehicleInfo? vehicle,
    DeliveryLicenseInfo? license,
    DeliveryBankInfo? bankAccount,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (vehicle != null) data['vehicle'] = vehicle.toJson();
      if (license != null) data['license'] = license.toJson();
      if (bankAccount != null) data['bankAccount'] = bankAccount.toJson();

      final res = await _dio.patch('/delivery/profile',
          data: data, options: await _authOptions());
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryProfile.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update profile');
    }
  }

  @override
  Future<void> toggleAvailability() async {
    try {
      await _dio.patch('/delivery/profile/toggle-availability', options: await _authOptions());
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to toggle availability');
    }
  }
}
