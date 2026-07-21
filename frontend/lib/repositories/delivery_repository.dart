import 'package:dio/dio.dart';
import '../models/delivery_dashboard_model.dart';
import '../models/delivery_model.dart';
import '../models/delivery_profile_model.dart';
import '../models/earnings_model.dart';
import '../models/notification_model.dart';
import '../core/services/api_client.dart';

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
  Future<DeliveryOrder> confirmPickup(String deliveryId);
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
  final ApiClient _apiClient;

  PostgresDeliveryRepository(this._apiClient);

  @override
  Future<DeliveryDashboardModel> getDashboard() async {
    try {
      final res = await _apiClient.dio.get('/delivery/dashboard');
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
      final res = await _apiClient.dio.get('/delivery/statistics');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryStats.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return DeliveryStats.fromJson({});
  }

  @override
  Future<List<DeliveryOrder>> getDeliveries({String? status, int page = 1, int limit = 20}) async {
    try {
      final query = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) query['status'] = status;

      final res = await _apiClient.dio.get('/delivery', queryParameters: query);
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => DeliveryOrder.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<DeliveryOrder> getDelivery(String deliveryId) async {
    try {
      final res = await _apiClient.dio.get('/delivery/$deliveryId');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Delivery details not found');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to load delivery details');
    }
  }

  @override
  Future<DeliveryOrder> acceptDelivery(String deliveryId) async {
    try {
      final res = await _apiClient.dio.patch('/delivery/$deliveryId/accept');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to accept delivery');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to accept delivery');
    }
  }

  @override
  Future<DeliveryOrder> rejectDelivery(String deliveryId, {String? reason}) async {
    try {
      final res = await _apiClient.dio.patch('/delivery/$deliveryId/reject', data: {
        if (reason != null) 'reason': reason,
      });
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to reject delivery');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to reject delivery');
    }
  }

  @override
  Future<DeliveryOrder> markPickedUp(String deliveryId) async {
    try {
      final res = await _apiClient.dio.patch('/delivery/$deliveryId/pickup');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to mark delivery picked up');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to mark delivery picked up');
    }
  }

  @override
  Future<DeliveryOrder> confirmPickup(String deliveryId) async {
    try {
      final res = await _apiClient.dio.patch('/delivery/$deliveryId/confirm-pickup');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to confirm pickup');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to confirm pickup');
    }
  }

  @override
  Future<DeliveryOrder> startDelivery(String deliveryId) async {
    try {
      final res = await _apiClient.dio.patch('/delivery/$deliveryId/start');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to start delivery');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to start delivery');
    }
  }

  @override
  Future<DeliveryOrder> verifyOtp(String deliveryId, String otp) async {
    try {
      final res = await _apiClient.dio.post('/delivery/$deliveryId/verify-otp', data: {'otp': otp});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Verification failed');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Verification failed');
    }
  }

  @override
  Future<DeliveryOrder> completeDelivery(String deliveryId) async {
    try {
      final res = await _apiClient.dio.patch('/delivery/$deliveryId/complete');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryOrder.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to complete delivery');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to complete delivery');
    }
  }

  @override
  Future<void> updateLocation(String deliveryId, double lat, double lng) async {
    try {
      await _apiClient.dio.patch('/delivery/$deliveryId/location', data: {
        'latitude': lat,
        'longitude': lng,
      });
    } catch (_) {}
  }

  @override
  Future<EarningsModel> getEarnings() async {
    try {
      final res = await _apiClient.dio.get('/delivery/earnings');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return EarningsModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return EarningsModel(totalEarnings: 0, pendingWithdrawals: 0, completedWithdrawals: 0);
  }

  @override
  Future<List<TransactionModel>> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiClient.dio.get('/delivery/transactions', queryParameters: {'page': page, 'limit': limit});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<DeliveryHistory> getHistory({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiClient.dio.get('/delivery/history', queryParameters: {'page': page, 'limit': limit});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryHistory.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return DeliveryHistory(orders: [], total: 0, page: page, limit: limit);
  }

  @override
  Future<List<AppNotificationModel>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiClient.dio.get('/notifications', queryParameters: {'page': page, 'limit': limit});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => AppNotificationModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _apiClient.dio.patch('/notifications/$notificationId/read');
    } catch (_) {}
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await _apiClient.dio.patch('/notifications/read-all');
    } catch (_) {}
  }

  @override
  Future<DeliveryProfile> getProfile() async {
    try {
      final res = await _apiClient.dio.get('/delivery/profile');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryProfile.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to load profile');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to load profile');
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
      if (bankAccount != null) data['bank'] = bankAccount.toJson();

      final res = await _apiClient.dio.patch('/delivery/profile', data: data);
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return DeliveryProfile.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? e.message ?? 'Failed to update profile');
    }
  }

  @override
  Future<void> toggleAvailability() async {
    try {
      await _apiClient.dio.patch('/delivery/toggle-availability');
    } catch (_) {}
  }
}
