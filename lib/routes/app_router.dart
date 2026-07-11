// Configures the application's routing using GoRouter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';

// Import feature screens
import '../features/splash/splash_screen.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/signup_screen.dart';
import '../features/home/customer_main_screen.dart';
import '../features/home/home_screen.dart';
import '../features/products/product_details_screen.dart';
import '../features/products/products_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/order_tracking_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/change_password_screen.dart';
import '../features/profile/addresses_screen.dart';
import '../features/profile/add_edit_address_screen.dart';
import '../models/address_model.dart';
import '../features/farmer/farmer_main_screen.dart';
import '../features/farmer/farmer_add_edit_product_screen.dart';
import '../features/farmer/farmer_edit_profile_screen.dart';
import '../features/farmer/farmer_inventory_screen.dart';
import '../features/farmer/farmer_withdrawal_screen.dart';
import '../features/farmer/farmer_notifications_screen.dart';
import '../features/farmer/farmer_order_detail_screen.dart';
import '../features/delivery/delivery_main_screen.dart';
import '../features/delivery/delivery_detail_screen.dart';
import '../features/delivery/delivery_navigation_screen.dart';
import '../features/delivery/delivery_earnings_screen.dart';
import '../features/delivery/delivery_history_screen.dart';
import '../features/delivery/delivery_notifications_screen.dart';
import '../features/delivery/delivery_profile_screen.dart';
import '../models/delivery_model.dart';

// Defines all the routes for the application
final GoRouter appRouter = GoRouter(
  initialLocation: '/login', // Start directly at login for demonstration
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    // Main Customer shell (Bottom Navigation)
    GoRoute(
      path: '/customer-main',
      name: 'customer-main',
      builder: (context, state) => const CustomerMainScreen(),
    ),
    // Main Farmer shell (Bottom Navigation)
    GoRoute(
      path: '/farmer-main',
      name: 'farmer-main',
      builder: (context, state) => const FarmerMainScreen(),
    ),
    // Main Delivery Partner shell
    GoRoute(
      path: '/delivery-main',
      name: 'delivery-main',
      builder: (context, state) => const DeliveryMainScreen(),
    ),
    GoRoute(
      path: '/delivery-detail',
      name: 'delivery-detail',
      builder: (context, state) {
        final deliveryId = state.extra as String;
        return DeliveryDetailScreen(deliveryId: deliveryId);
      },
    ),
    GoRoute(
      path: '/delivery-navigation',
      name: 'delivery-navigation',
      builder: (context, state) {
        final delivery = state.extra as DeliveryOrder;
        return DeliveryNavigationScreen(delivery: delivery);
      },
    ),
    GoRoute(
      path: '/delivery-earnings',
      name: 'delivery-earnings',
      builder: (context, state) => const DeliveryEarningsScreen(),
    ),
    GoRoute(
      path: '/delivery-history',
      name: 'delivery-history',
      builder: (context, state) => const DeliveryHistoryScreen(),
    ),
    GoRoute(
      path: '/delivery-notifications',
      name: 'delivery-notifications',
      builder: (context, state) => const DeliveryNotificationsScreen(),
    ),
    GoRoute(
      path: '/delivery-edit-profile',
      name: 'delivery-edit-profile',
      builder: (context, state) => const DeliveryProfileScreen(),
    ),
    // Sub-pages/Details
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/product-details',
      name: 'product-details',
      builder: (context, state) {
        final product = state.extra as ProductModel?;
        return ProductDetailsScreen(product: product);
      },
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return ProductsScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      name: 'wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/order-detail',
      name: 'order-detail',
      builder: (context, state) {
        final orderId = state.extra as String;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/order-tracking',
      name: 'order-tracking',
      builder: (context, state) {
        final orderId = state.extra as String;
        return OrderTrackingScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/addresses',
      name: 'addresses',
      builder: (context, state) => const AddressesScreen(),
    ),
    GoRoute(
      path: '/farmer-add-product',
      name: 'farmer-add-product',
      builder: (context, state) {
        final product = state.extra as ProductModel?;
        return FarmerAddEditProductScreen(product: product);
      },
    ),
    GoRoute(
      path: '/farmer-edit-profile',
      name: 'farmer-edit-profile',
      builder: (context, state) => const FarmerEditProfileScreen(),
    ),
    GoRoute(
      path: '/farmer-inventory',
      name: 'farmer-inventory',
      builder: (context, state) => const FarmerInventoryScreen(),
    ),
    GoRoute(
      path: '/farmer-withdrawal',
      name: 'farmer-withdrawal',
      builder: (context, state) => const FarmerWithdrawalScreen(),
    ),
    GoRoute(
      path: '/farmer-notifications',
      name: 'farmer-notifications',
      builder: (context, state) => const FarmerNotificationsScreen(),
    ),
    GoRoute(
      path: '/farmer-order-detail',
      name: 'farmer-order-detail',
      builder: (context, state) {
        final orderId = state.extra as String;
        return FarmerOrderDetailScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/add-address',
      name: 'add-address',
      builder: (context, state) => const AddEditAddressScreen(),
    ),
    GoRoute(
      path: '/edit-address',
      name: 'edit-address',
      builder: (context, state) {
        final address = state.extra as AddressModel;
        return AddEditAddressScreen(address: address);
      },
    ),
  ],
);
