import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farmer_dashboard_model.dart';
import '../models/inventory_model.dart';
import '../models/earnings_model.dart';
import '../models/withdrawal_model.dart';
import '../models/bank_account_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import 'app_providers.dart';

// ── Dashboard ──────────────────────────────────────────────

class FarmerDashboardState {
  final FarmerDashboardModel dashboard;
  final FarmerStatisticsModel statistics;
  final bool isLoading;
  final String? errorMessage;

  FarmerDashboardState({
    this.dashboard = const FarmerDashboardModel(),
    this.statistics = const FarmerStatisticsModel(),
    this.isLoading = false,
    this.errorMessage,
  });

  FarmerDashboardState copyWith({
    FarmerDashboardModel? dashboard,
    FarmerStatisticsModel? statistics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FarmerDashboardState(
      dashboard: dashboard ?? this.dashboard,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FarmerDashboardNotifier extends StateNotifier<FarmerDashboardState> {
  final Ref _ref;

  FarmerDashboardNotifier(this._ref) : super(FarmerDashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dashboard = await _ref.read(farmerRepositoryProvider).getDashboard();
      final statistics = await _ref.read(farmerRepositoryProvider).getStatistics();
      state = state.copyWith(
        dashboard: dashboard,
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final farmerDashboardProvider =
    StateNotifierProvider<FarmerDashboardNotifier, FarmerDashboardState>((ref) {
  return FarmerDashboardNotifier(ref);
});

// ── Inventory ──────────────────────────────────────────────

class FarmerInventoryState {
  final List<InventoryModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final String? actionMessage;

  FarmerInventoryState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
    this.actionMessage,
  });

  FarmerInventoryState copyWith({
    List<InventoryModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    String? actionMessage,
  }) {
    return FarmerInventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }
}

class FarmerInventoryNotifier extends StateNotifier<FarmerInventoryState> {
  final Ref _ref;

  FarmerInventoryNotifier(this._ref) : super(FarmerInventoryState()) {
    loadInventory();
  }

  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _ref.read(farmerRepositoryProvider).getInventory(page: 1, limit: 20);
      state = FarmerInventoryState(
        items: items,
        hasMore: items.length >= 20,
      );
    } catch (e) {
      state = FarmerInventoryState(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getInventory(page: nextPage, limit: 20);
      state = state.copyWith(
        items: [...state.items, ...more],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> updateStock(String inventoryId, double quantity) async {
    try {
      final updated = await _ref.read(farmerRepositoryProvider).updateStock(inventoryId, quantity);
      final newList = state.items.map((i) => i.id == inventoryId ? updated : i).toList();
      state = state.copyWith(items: newList, actionMessage: 'Stock updated');
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addStock(String inventoryId, double quantity) async {
    try {
      final updated = await _ref.read(farmerRepositoryProvider).addStock(inventoryId, quantity);
      final newList = state.items.map((i) => i.id == inventoryId ? updated : i).toList();
      state = state.copyWith(items: newList, actionMessage: 'Stock added');
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeStock(String inventoryId, double quantity) async {
    try {
      final updated = await _ref.read(farmerRepositoryProvider).removeStock(inventoryId, quantity);
      final newList = state.items.map((i) => i.id == inventoryId ? updated : i).toList();
      state = state.copyWith(items: newList, actionMessage: 'Stock removed');
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, actionMessage: null);
  }
}

final farmerInventoryProvider =
    StateNotifierProvider<FarmerInventoryNotifier, FarmerInventoryState>((ref) {
  return FarmerInventoryNotifier(ref);
});

// ── Earnings ───────────────────────────────────────────────

class FarmerEarningsState {
  final EarningsModel earnings;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  FarmerEarningsState({
    this.earnings = const EarningsModel(),
    this.transactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  FarmerEarningsState copyWith({
    EarningsModel? earnings,
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return FarmerEarningsState(
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

class FarmerEarningsNotifier extends StateNotifier<FarmerEarningsState> {
  final Ref _ref;

  FarmerEarningsNotifier(this._ref) : super(FarmerEarningsState()) {
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final earnings = await _ref.read(farmerRepositoryProvider).getEarnings();
      final transactions = await _ref.read(farmerRepositoryProvider).getTransactions(page: 1, limit: 20);
      state = FarmerEarningsState(
        earnings: earnings,
        transactions: transactions,
        hasMore: transactions.length >= 20,
      );
    } catch (e) {
      state = FarmerEarningsState(errorMessage: e.toString());
    }
  }

  Future<void> loadMoreTransactions() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getTransactions(page: nextPage, limit: 20);
      state = state.copyWith(
        transactions: [...state.transactions, ...more],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final farmerEarningsProvider =
    StateNotifierProvider<FarmerEarningsNotifier, FarmerEarningsState>((ref) {
  return FarmerEarningsNotifier(ref);
});

// ── Withdrawals ────────────────────────────────────────────

class FarmerWithdrawalState {
  final List<WithdrawalModel> withdrawals;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final String? actionMessage;

  FarmerWithdrawalState({
    this.withdrawals = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
    this.actionMessage,
  });

  FarmerWithdrawalState copyWith({
    List<WithdrawalModel>? withdrawals,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    String? actionMessage,
  }) {
    return FarmerWithdrawalState(
      withdrawals: withdrawals ?? this.withdrawals,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }
}

class FarmerWithdrawalNotifier extends StateNotifier<FarmerWithdrawalState> {
  final Ref _ref;

  FarmerWithdrawalNotifier(this._ref) : super(FarmerWithdrawalState()) {
    loadWithdrawals();
  }

  Future<void> loadWithdrawals() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final withdrawals = await _ref.read(farmerRepositoryProvider).getWithdrawals(page: 1, limit: 20);
      state = FarmerWithdrawalState(
        withdrawals: withdrawals,
        hasMore: withdrawals.length >= 20,
      );
    } catch (e) {
      state = FarmerWithdrawalState(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getWithdrawals(page: nextPage, limit: 20);
      state = state.copyWith(
        withdrawals: [...state.withdrawals, ...more],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> requestWithdrawal(double amount, {String? bankAccountId}) async {
    try {
      final withdrawal = await _ref.read(farmerRepositoryProvider).requestWithdrawal(amount, bankAccountId: bankAccountId);
      state = state.copyWith(
        withdrawals: [withdrawal, ...state.withdrawals],
        actionMessage: 'Withdrawal request submitted',
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateBankAccount(BankAccountModel account) async {
    try {
      await _ref.read(farmerRepositoryProvider).updateBankAccount(account);
      state = state.copyWith(actionMessage: 'Bank account updated');
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, actionMessage: null);
  }
}

final farmerWithdrawalProvider =
    StateNotifierProvider<FarmerWithdrawalNotifier, FarmerWithdrawalState>((ref) {
  return FarmerWithdrawalNotifier(ref);
});

// ── Notifications ──────────────────────────────────────────

class FarmerNotificationState {
  final List<AppNotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  FarmerNotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  FarmerNotificationState copyWith({
    List<AppNotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return FarmerNotificationState(
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

class FarmerNotificationNotifier extends StateNotifier<FarmerNotificationState> {
  final Ref _ref;

  FarmerNotificationNotifier(this._ref) : super(FarmerNotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final notifications = await _ref.read(farmerRepositoryProvider).getNotifications(page: 1, limit: 20);
      final unread = notifications.where((n) => !n.isRead).length;
      state = FarmerNotificationState(
        notifications: notifications,
        unreadCount: unread,
        hasMore: notifications.length >= 20,
      );
    } catch (e) {
      state = FarmerNotificationState(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getNotifications(page: nextPage, limit: 20);
      final all = [...state.notifications, ...more];
      state = state.copyWith(
        notifications: all,
        unreadCount: all.where((n) => !n.isRead).length,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> markRead(String notificationId) async {
    await _ref.read(farmerRepositoryProvider).markNotificationRead(notificationId);
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
    await _ref.read(farmerRepositoryProvider).markAllNotificationsRead();
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

final farmerNotificationProvider =
    StateNotifierProvider<FarmerNotificationNotifier, FarmerNotificationState>((ref) {
  return FarmerNotificationNotifier(ref);
});

// ── Farmer Orders (separate from customer orders) ──────────

class FarmerOrderState {
  final List<OrderModel> pendingOrders;
  final List<OrderModel> acceptedOrders;
  final List<OrderModel> preparingOrders;
  final List<OrderModel> readyOrders;
  final List<OrderModel> deliveredOrders;
  final List<OrderModel> cancelledOrders;
  final OrderModel? selectedOrder;
  final bool isLoading;
  final String? errorMessage;
  final String? actionMessage;

  FarmerOrderState({
    this.pendingOrders = const [],
    this.acceptedOrders = const [],
    this.preparingOrders = const [],
    this.readyOrders = const [],
    this.deliveredOrders = const [],
    this.cancelledOrders = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.errorMessage,
    this.actionMessage,
  });

  FarmerOrderState copyWith({
    List<OrderModel>? pendingOrders,
    List<OrderModel>? acceptedOrders,
    List<OrderModel>? preparingOrders,
    List<OrderModel>? readyOrders,
    List<OrderModel>? deliveredOrders,
    List<OrderModel>? cancelledOrders,
    OrderModel? selectedOrder,
    bool? isLoading,
    String? errorMessage,
    String? actionMessage,
  }) {
    return FarmerOrderState(
      pendingOrders: pendingOrders ?? this.pendingOrders,
      acceptedOrders: acceptedOrders ?? this.acceptedOrders,
      preparingOrders: preparingOrders ?? this.preparingOrders,
      readyOrders: readyOrders ?? this.readyOrders,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }
}

class FarmerOrderNotifier extends StateNotifier<FarmerOrderState> {
  final Ref _ref;

  FarmerOrderNotifier(this._ref) : super(FarmerOrderState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final all = await _ref.read(orderRepositoryProvider).getFarmerOrders(page: 1, limit: 100);
      state = state.copyWith(
        pendingOrders: all.where((o) => o.status.toUpperCase() == 'PENDING').toList(),
        acceptedOrders: all.where((o) => o.status.toUpperCase() == 'ACCEPTED').toList(),
        preparingOrders: all.where((o) => o.status.toUpperCase() == 'PREPARING').toList(),
        readyOrders: all.where((o) => o.status.toUpperCase() == 'READY_FOR_PICKUP').toList(),
        deliveredOrders: all.where((o) => const {'DELIVERED', 'COMPLETED'}.contains(o.status.toUpperCase())).toList(),
        cancelledOrders: all.where((o) => const {'CANCELLED', 'REJECTED'}.contains(o.status.toUpperCase())).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _ref.read(orderRepositoryProvider).updateOrderStatus(orderId, status);
      state = state.copyWith(actionMessage: 'Order updated to $status');
      await loadOrders();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, actionMessage: null);
  }
}

final farmerOrderProvider =
    StateNotifierProvider<FarmerOrderNotifier, FarmerOrderState>((ref) {
  return FarmerOrderNotifier(ref);
});
