import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../core/constants/app_constants.dart';

class CartSummary {
  final double subtotal;
  final double discount;
  final double tax;
  final double deliveryCharge;
  final double grandTotal;

  const CartSummary({
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.deliveryCharge = 0,
    this.grandTotal = 0,
  });
}

abstract class CartRepository {
  Future<List<CartItemModel>> getCart();
  Future<CartSummary> getCartSummary();
  Future<void> updateCart(List<CartItemModel> items);
  Future<void> clearCart();
  Future<void> addItemToBackend(String productId, int quantity);
  Future<void> updateItemQuantity(String cartItemId, int quantity);
  Future<void> removeItemById(String cartItemId);
}

class PostgresCartRepository implements CartRepository {
  final Dio _dio;

  PostgresCartRepository() : _dio = Dio(BaseOptions(
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
  Future<List<CartItemModel>> getCart() async {
    try {
      final res = await _dio.get('/cart', options: await _authOptions());

      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final cartData = res.data['data'];
        final items = cartData['items'] as List? ?? [];
        return items.map<CartItemModel>((item) {
          return CartItemModel.fromBackendJson(item as Map<String, dynamic>);
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<CartSummary> getCartSummary() async {
    try {
      final res = await _dio.get('/cart/summary', options: await _authOptions());

      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final d = res.data['data'];
        return CartSummary(
          subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0,
          discount: (d['discount'] as num?)?.toDouble() ?? 0,
          tax: (d['tax'] as num?)?.toDouble() ?? 0,
          deliveryCharge: (d['deliveryCharge'] as num?)?.toDouble() ?? 0,
          grandTotal: (d['grandTotal'] as num?)?.toDouble() ?? 0,
        );
      }
    } catch (_) {}
    return const CartSummary();
  }

  @override
  Future<void> addItemToBackend(String productId, int quantity) async {
    try {
      await _dio.post('/cart/items', data: {
        'productId': productId,
        'quantity': quantity,
      }, options: await _authOptions());
    } catch (_) {}
  }

  @override
  Future<void> updateItemQuantity(String cartItemId, int quantity) async {
    try {
      await _dio.patch('/cart/items/$cartItemId', data: {
        'quantity': quantity,
      }, options: await _authOptions());
    } catch (_) {}
  }

  @override
  Future<void> removeItemById(String cartItemId) async {
    try {
      await _dio.delete('/cart/items/$cartItemId', options: await _authOptions());
    } catch (_) {}
  }

  @override
  Future<void> updateCart(List<CartItemModel> items) async {
    try {
      for (final item in items) {
        await _dio.post('/cart/items', data: {
          'productId': item.product.id,
          'quantity': item.quantity,
        }, options: await _authOptions());
      }
    } catch (_) {}
  }

  @override
  Future<void> clearCart() async {
    try {
      await _dio.delete('/cart/clear', options: await _authOptions());
    } catch (_) {}
  }
}
