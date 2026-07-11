import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/address_repository.dart';
import '../repositories/farmer_repository.dart';
import '../repositories/delivery_repository.dart';
import '../core/services/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresAuthRepository(apiClient);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresProductRepository(apiClient);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresCartRepository(apiClient);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresOrderRepository(apiClient);
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresAddressRepository(apiClient);
});

final farmerRepositoryProvider = Provider<FarmerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresFarmerRepository(apiClient);
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostgresDeliveryRepository(apiClient);
});
