import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/address_repository.dart';
import '../repositories/farmer_repository.dart';
import '../repositories/delivery_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return PostgresAuthRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return PostgresProductRepository();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return PostgresCartRepository();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return PostgresOrderRepository();
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return PostgresAddressRepository();
});

final farmerRepositoryProvider = Provider<FarmerRepository>((ref) {
  return PostgresFarmerRepository();
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return PostgresDeliveryRepository();
});
