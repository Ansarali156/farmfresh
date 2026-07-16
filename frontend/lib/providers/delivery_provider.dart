import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery_dashboard_model.dart';
import '../models/delivery_model.dart';
import '../models/delivery_profile_model.dart';
import '../models/earnings_model.dart';
import '../models/notification_model.dart';
import 'app_providers.dart';

// ── Dashboard ──────────────────────────────────────────────

class DeliveryDashboardState {
  final DeliveryDashboardModel dashboard;
  final DeliveryStats stats;
  final bool isLoading;
  final String? errorMessage;

  DeliveryDashboardState({
    DeliveryDashboardModel? dashboard,
    DeliveryStats? stats,
    this.isLoading = false,
    this.errorMessage,
  })  : dashboard = dashboard ?? DeliveryDashboardModel(
          stats: const DeliveryStats(),
          recentEarnings: const [],
          unreadNotifications: 0,
        ),
        stats = stats ?? const DeliveryStats();

  DeliveryDashboardState copyWith({
    DeliveryDashboardModel? dashboard,
    DeliveryStats? stats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DeliveryDashboardState(
      dashboard: dashboard ?? this.dashboard,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DeliveryDashboardNotifier extends StateNotifier<DeliveryDashboardState> {
  final Ref _ref;
  bool _mounted = true;

  DeliveryDashboardNotifier(this._ref) : super(DeliveryDashboardState()) {
    loadDashboard();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadDashboard() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dashboard = await _ref.read(deliveryRepositoryProvider).getDashboard();
      if (!_mounted) return;
      final stats = await _ref.read(deliveryRepositoryProvider).getStatistics();
      if (!_mounted) return;
      state = state.copyWith(
        dashboard: dashboard,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final deliveryDashboardProvider =
    StateNotifierProvider<DeliveryDashboardNotifier, DeliveryDashboardState>((ref) {
  return DeliveryDashboardNotifier(ref);
});

// ── Active Deliveries ──────────────────────────────────────

class DeliveryOrdersState {
  final List<DeliveryOrder> pendingDeliveries;
  final List<DeliveryOrder> activeDeliveries;
  final DeliveryOrder? selectedDelivery;
  final bool isLoading;
  final String? errorMessage;
  final String? actionMessage;
  final bool isPerformingAction;

  DeliveryOrdersState({
    this.pendingDeliveries = const [],
    this.activeDeliveries = const [],
    this.selectedDelivery,
    this.isLoading = false,
    this.errorMessage,
    this.actionMessage,
    this.isPerformingAction = false,
  });

  DeliveryOrdersState copyWith({
    List<DeliveryOrder>? pendingDeliveries,
    List<DeliveryOrder>? activeDeliveries,
    DeliveryOrder? selectedDelivery,
    bool? isLoading,
    String? errorMessage,
    String? actionMessage,
    bool? isPerformingAction,
  }) {
    return DeliveryOrdersState(
      pendingDeliveries: pendingDeliveries ?? this.pendingDeliveries,
      activeDeliveries: activeDeliveries ?? this.activeDeliveries,
      selectedDelivery: selectedDelivery ?? this.selectedDelivery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }
}

class DeliveryOrdersNotifier extends StateNotifier<DeliveryOrdersState> {
  final Ref _ref;
  bool _mounted = true;

  DeliveryOrdersNotifier(this._ref) : super(DeliveryOrdersState()) {
    loadDeliveries();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadDeliveries() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final pending = await _ref.read(deliveryRepositoryProvider).getDeliveries(status: 'PENDING');
      if (!_mounted) return;
      final active = await _ref.read(deliveryRepositoryProvider).getDeliveries(status: 'ACCEPTED');
      if (!_mounted) return;
      final headingToPickup = await _ref.read(deliveryRepositoryProvider).getDeliveries(status: 'HEADING_TO_PICKUP');
      if (!_mounted) return;
      final pickedUp = await _ref.read(deliveryRepositoryProvider).getDeliveries(status: 'PICKED_UP');
      if (!_mounted) return;
      final outForDelivery = await _ref.read(deliveryRepositoryProvider).getDeliveries(status: 'OUT_FOR_DELIVERY');
      if (!_mounted) return;
      state = state.copyWith(
        pendingDeliveries: pending,
        activeDeliveries: [...active, ...headingToPickup, ...pickedUp, ...outForDelivery],
        isLoading: false,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadDelivery(String deliveryId) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final delivery = await _ref.read(deliveryRepositoryProvider).getDelivery(deliveryId);
      if (!_mounted) return;
      state = state.copyWith(selectedDelivery: delivery, isLoading: false);
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> acceptDelivery(String deliveryId) async {
    if (!_mounted) return false;
    state = state.copyWith(isPerformingAction: true, errorMessage: null);
    try {
      final updated = await _ref.read(deliveryRepositoryProvider).acceptDelivery(deliveryId);
      if (!_mounted) return false;
      state = state.copyWith(
        selectedDelivery: updated,
        isPerformingAction: false,
        actionMessage: 'Delivery accepted',
      );
      await loadDeliveries();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> rejectDelivery(String deliveryId, {String? reason}) async {
    if (!_mounted) return false;
    state = state.copyWith(isPerformingAction: true, errorMessage: null);
    try {
      await _ref.read(deliveryRepositoryProvider).rejectDelivery(deliveryId, reason: reason);
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, actionMessage: 'Delivery rejected');
      await loadDeliveries();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> markPickedUp(String deliveryId) async {
    if (!_mounted) return false;
    state = state.copyWith(isPerformingAction: true, errorMessage: null);
    try {
      final updated = await _ref.read(deliveryRepositoryProvider).markPickedUp(deliveryId);
      if (!_mounted) return false;
      state = state.copyWith(
        selectedDelivery: updated,
        isPerformingAction: false,
        actionMessage: 'Picked up from farmer',
      );
      await loadDeliveries();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> confirmPickup(String deliveryId) async {
    if (!_mounted) return false;
    state = state.copyWith(isPerformingAction: true, errorMessage: null);
    try {
      final updated = await _ref.read(deliveryRepositoryProvider).confirmPickup(deliveryId);
      if (!_mounted) return false;
      state = state.copyWith(
        selectedDelivery: updated,
        isPerformingAction: false,
        actionMessage: 'Pickup confirmed at farm',
      );
      await loadDeliveries();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> startDelivery(String deliveryId) async {
    if (!_mounted) return false;
    state = state.copyWith(isPerformingAction: true, errorMessage: null);
    try {
      final updated = await _ref.read(deliveryRepositoryProvider).startDelivery(deliveryId);
      if (!_mounted) return false;
      state = state.copyWith(
        selectedDelivery: updated,
        isPerformingAction: false,
        actionMessage: 'Delivery started',
      );
      await loadDeliveries();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String deliveryId, String otp) async {
    if (!_mounted) return false;
    state = state.copyWith(isPerformingAction: true, errorMessage: null);
    try {
      final updated = await _ref.read(deliveryRepositoryProvider).verifyOtp(deliveryId, otp);
      if (!_mounted) return false;
      state = state.copyWith(
        selectedDelivery: updated,
        isPerformingAction: false,
        actionMessage: 'OTP verified, delivery completing',
      );
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> completeDelivery(String deliveryId) async {
    if (!_mounted) return false;
    state = state.copyWith(isPerformingAction: true, errorMessage: null);
    try {
      final updated = await _ref.read(deliveryRepositoryProvider).completeDelivery(deliveryId);
      if (!_mounted) return false;
      state = state.copyWith(
        selectedDelivery: updated,
        isPerformingAction: false,
        actionMessage: 'Delivery completed',
      );
      await loadDeliveries();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(isPerformingAction: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    if (!_mounted) return;
    state = state.copyWith(errorMessage: null, actionMessage: null);
  }
}

final deliveryOrdersProvider =
    StateNotifierProvider<DeliveryOrdersNotifier, DeliveryOrdersState>((ref) {
  return DeliveryOrdersNotifier(ref);
});

// ── Earnings ───────────────────────────────────────────────

class DeliveryEarningsState {
  final EarningsModel earnings;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  DeliveryEarningsState({
    this.earnings = const EarningsModel(),
    this.transactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  DeliveryEarningsState copyWith({
    EarningsModel? earnings,
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return DeliveryEarningsState(
      earnings: earnings ?? this.earnings,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

class DeliveryEarningsNotifier extends StateNotifier<DeliveryEarningsState> {
  final Ref _ref;
  bool _mounted = true;

  DeliveryEarningsNotifier(this._ref) : super(DeliveryEarningsState()) {
    loadEarnings();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadEarnings() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final earnings = await _ref.read(deliveryRepositoryProvider).getEarnings();
      if (!_mounted) return;
      final transactions = await _ref.read(deliveryRepositoryProvider).getTransactions(page: 1, limit: 20);
      if (!_mounted) return;
      state = DeliveryEarningsState(
        earnings: earnings,
        transactions: transactions,
        hasMore: transactions.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = DeliveryEarningsState(errorMessage: e.toString());
    }
  }

  Future<void> loadMoreTransactions() async {
    if (!_mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(deliveryRepositoryProvider).getTransactions(page: nextPage, limit: 20);
      if (!_mounted) return;
      state = state.copyWith(
        transactions: [...state.transactions, ...more],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final deliveryEarningsProvider =
    StateNotifierProvider<DeliveryEarningsNotifier, DeliveryEarningsState>((ref) {
  return DeliveryEarningsNotifier(ref);
});

// ── Notifications ──────────────────────────────────────────

class DeliveryNotificationState {
  final List<AppNotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  DeliveryNotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  DeliveryNotificationState copyWith({
    List<AppNotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return DeliveryNotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

class DeliveryNotificationNotifier extends StateNotifier<DeliveryNotificationState> {
  final Ref _ref;
  bool _mounted = true;

  DeliveryNotificationNotifier(this._ref) : super(DeliveryNotificationState()) {
    loadNotifications();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadNotifications() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final notifications = await _ref.read(deliveryRepositoryProvider).getNotifications(page: 1, limit: 20);
      if (!_mounted) return;
      final unread = notifications.where((n) => !n.isRead).length;
      state = DeliveryNotificationState(
        notifications: notifications,
        unreadCount: unread,
        hasMore: notifications.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = DeliveryNotificationState(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!_mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(deliveryRepositoryProvider).getNotifications(page: nextPage, limit: 20);
      if (!_mounted) return;
      final all = [...state.notifications, ...more];
      state = state.copyWith(
        notifications: all,
        unreadCount: all.where((n) => !n.isRead).length,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> markRead(String notificationId) async {
    if (!_mounted) return;
    await _ref.read(deliveryRepositoryProvider).markNotificationRead(notificationId);
    if (!_mounted) return;
    final updated = state.notifications
        .map((n) => n.id == notificationId
            ? AppNotificationModel(
                id: n.id,
                title: n.title,
                body: n.body,
                type: n.type,
                isRead: true,
                createdAt: n.createdAt,
                data: n.data,
              )
            : n)
        .toList();
    state = state.copyWith(
      notifications: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    );
  }

  Future<void> markAllRead() async {
    if (!_mounted) return;
    await _ref.read(deliveryRepositoryProvider).markAllNotificationsRead();
    if (!_mounted) return;
    final updated = state.notifications
        .map((n) => AppNotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
              data: n.data,
            ))
        .toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
  }
}

final deliveryNotificationProvider =
    StateNotifierProvider<DeliveryNotificationNotifier, DeliveryNotificationState>((ref) {
  return DeliveryNotificationNotifier(ref);
});

// ── Profile ──────────────────────────────────────────────────

class DeliveryProfileState {
  final DeliveryProfile profile;
  final bool isLoading;
  final String? errorMessage;
  final String? actionMessage;

  DeliveryProfileState({
    DeliveryProfile? profile,
    this.isLoading = false,
    this.errorMessage,
    this.actionMessage,
  }) : profile = profile ?? DeliveryProfile(
          id: '',
          name: '',
          phone: '',
          rating: const DeliveryRatingInfo(average: 0, totalRatings: 0, fiveStarCount: 0, fourStarCount: 0, threeStarCount: 0, twoStarCount: 0, oneStarCount: 0),
          isAvailable: false,
        );

  DeliveryProfileState copyWith({
    DeliveryProfile? profile,
    bool? isLoading,
    String? errorMessage,
    String? actionMessage,
  }) {
    return DeliveryProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }
}

class DeliveryProfileNotifier extends StateNotifier<DeliveryProfileState> {
  final Ref _ref;
  bool _mounted = true;

  DeliveryProfileNotifier(this._ref) : super(DeliveryProfileState()) {
    loadProfile();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadProfile() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _ref.read(deliveryRepositoryProvider).getProfile();
      if (!_mounted) return;
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? email,
    DeliveryVehicleInfo? vehicle,
    DeliveryLicenseInfo? license,
    DeliveryBankInfo? bankAccount,
  }) async {
    if (!_mounted) return false;
    state = state.copyWith(errorMessage: null, actionMessage: null);
    try {
      final updated = await _ref.read(deliveryRepositoryProvider).updateProfile(
        name: name,
        phone: phone,
        email: email,
        vehicle: vehicle,
        license: license,
        bankAccount: bankAccount,
      );
      if (!_mounted) return false;
      state = state.copyWith(profile: updated, actionMessage: 'Profile updated');
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> toggleAvailability() async {
    if (!_mounted) return false;
    try {
      await _ref.read(deliveryRepositoryProvider).toggleAvailability();
      if (!_mounted) return false;
      state = state.copyWith(
        profile: state.profile.copyWith(isAvailable: !state.profile.isAvailable),
        actionMessage: state.profile.isAvailable ? 'You are now offline' : 'You are now online',
      );
      _ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    if (!_mounted) return;
    state = state.copyWith(errorMessage: null, actionMessage: null);
  }
}

final deliveryProfileProvider =
    StateNotifierProvider<DeliveryProfileNotifier, DeliveryProfileState>((ref) {
  return DeliveryProfileNotifier(ref);
});

// ── History ──────────────────────────────────────────────────

class DeliveryHistoryState {
  final List<DeliveryOrder> orders;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  DeliveryHistoryState({
    this.orders = const [],
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  DeliveryHistoryState copyWith({
    List<DeliveryOrder>? orders,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return DeliveryHistoryState(
      orders: orders ?? this.orders,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

class DeliveryHistoryNotifier extends StateNotifier<DeliveryHistoryState> {
  final Ref _ref;
  bool _mounted = true;

  DeliveryHistoryNotifier(this._ref) : super(DeliveryHistoryState()) {
    loadHistory();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadHistory() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final history = await _ref.read(deliveryRepositoryProvider).getHistory(page: 1, limit: 20);
      if (!_mounted) return;
      state = DeliveryHistoryState(
        orders: history.orders,
        total: history.total,
        hasMore: history.orders.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = DeliveryHistoryState(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!_mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final history = await _ref.read(deliveryRepositoryProvider).getHistory(page: nextPage, limit: 20);
      if (!_mounted) return;
      state = state.copyWith(
        orders: [...state.orders, ...history.orders],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: history.orders.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final deliveryHistoryProvider =
    StateNotifierProvider<DeliveryHistoryNotifier, DeliveryHistoryState>((ref) {
  return DeliveryHistoryNotifier(ref);
});