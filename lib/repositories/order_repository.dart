import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../core/services/api_client.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<List<OrderModel>> getCustomerOrders({int page = 1, int limit = 10});
  Future<List<OrderModel>> getFarmerOrders({int page = 1, int limit = 10, String? status});
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> createOrder(OrderModel order, {String? address, String? notes});
  Future<OrderModel> updateOrderStatus(String orderId, String status);
  Future<void> cancelOrder(String orderId, {String? reason});
  Future<void> reorder(String orderId);
}

class PostgresOrderRepository implements OrderRepository {
  final ApiClient _apiClient;

  PostgresOrderRepository(this._apiClient);

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final res = await _apiClient.dio.get('/orders');

      if (res.statusCode == 200 &&
          res.data['success'] == true &&
          res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list
            .map((item) => OrderModel.fromBackendJson(item))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<OrderModel>> getFarmerOrders({int page = 1, int limit = 10, String? status}) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) query['status'] = status;

      final res = await _apiClient.dio.get('/orders/farmer', queryParameters: query);

      if (res.statusCode == 200 &&
          res.data['success'] == true &&
          res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list
            .map((item) => OrderModel.fromBackendJson(item))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<OrderModel>> getCustomerOrders({int page = 1, int limit = 10}) async {
    try {
      final res = await _apiClient.dio.get('/orders/customer', queryParameters: {'page': page, 'limit': limit});

      if (res.statusCode == 200 &&
          res.data['success'] == true &&
          res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list
            .map((item) => OrderModel.fromBackendJson(item))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final res = await _apiClient.dio.get('/orders/$orderId');

      if (res.statusCode == 200 &&
          res.data['success'] == true &&
          res.data['data'] != null) {
        return OrderModel.fromBackendJson(res.data['data']);
      }
      throw Exception('Order not found');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? e.message ?? 'Failed to load order');
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order, {String? address, String? notes}) async {
    try {
      final itemsPayload = order.items
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      final res = await _apiClient.dio.post('/orders', data: {
        'address': address ?? '',
        'notes': notes ?? '',
        'items': itemsPayload,
      });

      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return OrderModel.fromBackendJson(res.data['data']);
        }
      }
      throw Exception('Failed to create order');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to create order');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final res = await _apiClient.dio.patch('/orders/$orderId/status', data: {'status': status});

      if (res.statusCode == 200) {
        if (res.data['success'] == true && res.data['data'] != null) {
          return OrderModel.fromBackendJson(res.data['data']);
        }
      }
      throw Exception('Failed to update order status');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to update order status');
    }
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      final res = await _apiClient.dio.patch('/orders/$orderId/cancel', data: {
        if (reason != null) 'reason': reason,
      });

      if (res.statusCode != 200) {
        throw Exception(res.data['message'] ?? 'Failed to cancel order');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to cancel order');
    }
  }

  @override
  Future<void> reorder(String orderId) async {
    try {
      final res = await _apiClient.dio.post('/orders/$orderId/reorder');

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(res.data['message'] ?? 'Failed to reorder');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to reorder');
    }
  }
}
