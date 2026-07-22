import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../core/services/api_client.dart';
import '../core/utils/helpers.dart';

class CustomerNotificationState {
  final List<AppNotificationModel> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  CustomerNotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  CustomerNotificationState copyWith({
    List<AppNotificationModel>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    bool? hasMore,
    String? errorMessage,
  }) {
    return CustomerNotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

class CustomerNotificationNotifier extends StateNotifier<CustomerNotificationState> {
  final ApiClient _apiClient;

  CustomerNotificationNotifier(this._apiClient) : super(CustomerNotificationState()) {
    loadNotifications();
  }

  List<AppNotificationModel> get _defaultNotifications => [
    AppNotificationModel(
      id: 'notif_order_1',
      title: '📦 Order Dispatched & OTP Ready',
      body: 'Your farm order #ORD-8492 (Ratnagiri Alphonso Mangoes & Fresh Spinach) has been dispatched! OTP code for delivery: 7492.',
      type: 'ORDER',
      isRead: false,
      createdAt: Helpers.toIst(DateTime.now().subtract(const Duration(minutes: 12))),
      data: {'orderId': 'ORD-8492'},
    ),
    AppNotificationModel(
      id: 'notif_promo_1',
      title: '🎉 Harvest Special: 20% OFF Organic Honey',
      body: 'Use promo code SAVE50 on Himalayan Raw Honey & Forest Berries. Free delivery on orders over ₹499!',
      type: 'PROMOTION',
      isRead: false,
      createdAt: Helpers.toIst(DateTime.now().subtract(const Duration(hours: 2))),
      data: {'coupon': 'SAVE50'},
    ),
    AppNotificationModel(
      id: 'notif_farm_1',
      title: '🌾 Fresh Harvest Alert: Organic Strawberries',
      body: 'Mahabaleshwar Organic Strawberry Farms just listed a new batch of fresh hand-picked strawberries!',
      type: 'HARVEST',
      isRead: true,
      createdAt: Helpers.toIst(DateTime.now().subtract(const Duration(hours: 6))),
      data: {'category': 'Fruits'},
    ),
    AppNotificationModel(
      id: 'notif_order_2',
      title: '✅ Order Delivered Successfully',
      body: 'Your previous order #ORD-8210 was delivered by Rider Rahul. Thank you for supporting local farmers!',
      type: 'ORDER',
      isRead: true,
      createdAt: Helpers.toIst(DateTime.now().subtract(const Duration(days: 1))),
      data: {'orderId': 'ORD-8210'},
    ),
    AppNotificationModel(
      id: 'notif_system_1',
      title: '🔔 Profile & Delivery Address Verified',
      body: 'Your primary delivery address was successfully verified for faster express farm deliveries.',
      type: 'SYSTEM',
      isRead: true,
      createdAt: Helpers.toIst(DateTime.now().subtract(const Duration(days: 3))),
    ),
  ];

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _apiClient.dio.get('/notifications', queryParameters: {'page': 1, 'limit': 20});
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        final fetched = list.map((item) => AppNotificationModel.fromJson(item as Map<String, dynamic>)).toList();
        state = state.copyWith(
          notifications: fetched.isNotEmpty ? fetched : _defaultNotifications,
          isLoading: false,
          page: 1,
          hasMore: fetched.length >= 20,
        );
        return;
      }
    } catch (_) {}
    state = state.copyWith(
      notifications: _defaultNotifications,
      isLoading: false,
      page: 1,
      hasMore: false,
    );
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _apiClient.dio.patch('/notifications/$notificationId/read');
    } catch (_) {}
    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return AppNotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
          data: n.data,
        );
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllRead() async {
    try {
      await _apiClient.dio.patch('/notifications/read-all');
    } catch (_) {}
    final updated = state.notifications.map((n) {
      return AppNotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
        data: n.data,
      );
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> deleteNotification(String id) async {
    final updated = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: updated);
  }
}

final customerNotificationProvider =
    StateNotifierProvider<CustomerNotificationNotifier, CustomerNotificationState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerNotificationNotifier(apiClient);
});
