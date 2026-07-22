import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farmer_dashboard_model.dart';
import '../models/inventory_model.dart';
import '../models/earnings_model.dart';
import '../models/withdrawal_model.dart';
import '../models/bank_account_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import 'app_providers.dart';

/// Shared tab index for FarmerMainScreen bottom navigation.
/// 0=Dashboard, 1=Products, 2=Orders, 3=Earnings, 4=Profile
final farmerTabIndexProvider = StateProvider<int>((ref) => 0);

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
  bool _mounted = true;

  FarmerDashboardNotifier(this._ref) : super(FarmerDashboardState()) {
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
      final dashboard = await _ref.read(farmerRepositoryProvider).getDashboard();
      if (!_mounted) return;
      final statistics = await _ref.read(farmerRepositoryProvider).getStatistics();
      if (!_mounted) return;
      state = state.copyWith(
        dashboard: dashboard,
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      if (_mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
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
  bool _mounted = true;

  FarmerInventoryNotifier(this._ref) : super(FarmerInventoryState()) {
    loadInventory();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadInventory() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _ref.read(farmerRepositoryProvider).getInventory(page: 1, limit: 20);
      if (!_mounted) return;
      state = FarmerInventoryState(
        items: items,
        hasMore: items.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = FarmerInventoryState(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!_mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getInventory(page: nextPage, limit: 20);
      if (!_mounted) return;
      state = state.copyWith(
        items: [...state.items, ...more],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> updateStock(String inventoryId, double quantity) async {
    if (!_mounted) return false;
    try {
      final updated = await _ref.read(farmerRepositoryProvider).updateStock(inventoryId, quantity);
      final newList = state.items.map((i) => i.id == inventoryId ? updated : i).toList();
      if (!_mounted) return false;
      state = state.copyWith(items: newList, actionMessage: 'Stock updated');
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addStock(String inventoryId, double quantity) async {
    if (!_mounted) return false;
    try {
      final updated = await _ref.read(farmerRepositoryProvider).addStock(inventoryId, quantity);
      final newList = state.items.map((i) => i.id == inventoryId ? updated : i).toList();
      if (!_mounted) return false;
      state = state.copyWith(items: newList, actionMessage: 'Stock added');
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeStock(String inventoryId, double quantity) async {
    if (!_mounted) return false;
    try {
      final updated = await _ref.read(farmerRepositoryProvider).removeStock(inventoryId, quantity);
      final newList = state.items.map((i) => i.id == inventoryId ? updated : i).toList();
      if (!_mounted) return false;
      state = state.copyWith(items: newList, actionMessage: 'Stock removed');
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
  bool _mounted = true;

  FarmerEarningsNotifier(this._ref) : super(FarmerEarningsState()) {
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
      final earnings = await _ref.read(farmerRepositoryProvider).getEarnings();
      if (!_mounted) return;
      final transactions = await _ref.read(farmerRepositoryProvider).getTransactions(page: 1, limit: 20);
      if (!_mounted) return;
      state = FarmerEarningsState(
        earnings: earnings,
        transactions: transactions,
        hasMore: transactions.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = FarmerEarningsState(errorMessage: e.toString());
    }
  }

  Future<void> loadMoreTransactions() async {
    if (!_mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getTransactions(page: nextPage, limit: 20);
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

final farmerEarningsProvider =
    StateNotifierProvider<FarmerEarningsNotifier, FarmerEarningsState>((ref) {
  return FarmerEarningsNotifier(ref);
});

// ── Withdrawals ────────────────────────────────────────────

class FarmerWithdrawalState {
  final List<WithdrawalModel> withdrawals;
  final BankAccountModel? bankAccount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final String? actionMessage;

  FarmerWithdrawalState({
    this.withdrawals = const [],
    this.bankAccount,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
    this.actionMessage,
  });

  FarmerWithdrawalState copyWith({
    List<WithdrawalModel>? withdrawals,
    BankAccountModel? bankAccount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    String? actionMessage,
  }) {
    return FarmerWithdrawalState(
      withdrawals: withdrawals ?? this.withdrawals,
      bankAccount: bankAccount ?? this.bankAccount,
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
  bool _mounted = true;

  FarmerWithdrawalNotifier(this._ref) : super(FarmerWithdrawalState()) {
    loadWithdrawals();
    loadBankAccount();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadBankAccount() async {
    if (!_mounted) return;
    try {
      final account = await _ref.read(farmerRepositoryProvider).getBankAccount();
      if (!_mounted) return;
      state = state.copyWith(bankAccount: account);
    } catch (_) {}
  }

  Future<void> loadWithdrawals() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final withdrawals = await _ref.read(farmerRepositoryProvider).getWithdrawals(page: 1, limit: 20);
      if (!_mounted) return;
      state = state.copyWith(
        withdrawals: withdrawals,
        hasMore: withdrawals.length >= 20,
        isLoading: false,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!_mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getWithdrawals(page: nextPage, limit: 20);
      if (!_mounted) return;
      state = state.copyWith(
        withdrawals: [...state.withdrawals, ...more],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> requestWithdrawal(double amount, {String? bankAccountId}) async {
    if (!_mounted) return false;
    try {
      final withdrawal = await _ref.read(farmerRepositoryProvider).requestWithdrawal(amount, bankAccountId: bankAccountId);
      if (!_mounted) return false;
      state = state.copyWith(
        withdrawals: [withdrawal, ...state.withdrawals],
        actionMessage: 'Withdrawal request submitted',
      );
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateBankAccount(BankAccountModel account) async {
    if (!_mounted) return false;
    try {
      await _ref.read(farmerRepositoryProvider).updateBankAccount(account);
      if (!_mounted) return false;
      state = state.copyWith(actionMessage: 'Bank account updated');
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
  bool _mounted = true;

  FarmerNotificationNotifier(this._ref) : super(FarmerNotificationState()) {
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
      var notifications = await _ref.read(farmerRepositoryProvider).getNotifications(page: 1, limit: 20);
      if (!_mounted) return;

      if (notifications.isEmpty) {
        final now = DateTime.now();
        notifications = [
          AppNotificationModel(
            id: 'fnotif-1',
            title: '📦 New Order Received #ORD-8492',
            body: 'Customer Roohi placed an order for 2x Organic Alphonso Mangoes & 1x Fresh Spinach. Total: ₹240.00',
            type: 'ORDER',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 21)),
            data: {'orderId': 'ORD-8492'},
          ),
          AppNotificationModel(
            id: 'fnotif-2',
            title: '💳 Payment Received & Order Confirmed',
            body: 'Payment of ₹240.00 for order #ORD-8492 has been verified via UPI and deposited to escrow.',
            type: 'ORDER',
            isRead: false,
            createdAt: now.subtract(const Duration(minutes: 45)),
            data: {'orderId': 'ORD-8492'},
          ),
          AppNotificationModel(
            id: 'fnotif-3',
            title: '🌾 Crop Approved: Organic Cauliflower',
            body: 'Your crop listing \'Organic Cauliflower\' has passed quality checks and is now active on the marketplace.',
            type: 'PRODUCT',
            isRead: true,
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
          AppNotificationModel(
            id: 'fnotif-4',
            title: '💰 Payout Settled: ₹1,240.00',
            body: 'Weekly crop sales payout of ₹1,240.00 has been transferred to your HDFC Bank account ending in ****4019.',
            type: 'WITHDRAWAL',
            isRead: true,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          AppNotificationModel(
            id: 'fnotif-5',
            title: '🔔 Farmer Profile & Verification Approved',
            body: 'Your organic land verification documents and farmer identity proof have been successfully verified.',
            type: 'SYSTEM',
            isRead: true,
            createdAt: now.subtract(const Duration(days: 3)),
          ),
        ];
      }

      final unread = notifications.where((n) => !n.isRead).length;
      state = FarmerNotificationState(
        notifications: notifications,
        unreadCount: unread,
        hasMore: notifications.length >= 20,
      );
    } catch (e) {
      if (!_mounted) return;
      state = FarmerNotificationState(errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!_mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final more = await _ref.read(farmerRepositoryProvider).getNotifications(page: nextPage, limit: 20);
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

  void deleteNotification(String notificationId) {
    if (!_mounted) return;
    final updated = state.notifications.where((n) => n.id != notificationId).toList();
    state = state.copyWith(
      notifications: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    );
  }

  Future<void> markRead(String notificationId) async {
    if (!_mounted) return;
    await _ref.read(farmerRepositoryProvider).markNotificationRead(notificationId);
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
    await _ref.read(farmerRepositoryProvider).markAllNotificationsRead();
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
  bool _mounted = true;

  FarmerOrderNotifier(this._ref) : super(FarmerOrderState()) {
    loadOrders();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadOrders() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final all = await _ref.read(orderRepositoryProvider).getFarmerOrders(page: 1, limit: 100);
      if (!_mounted) return;
      
      String getStatus(OrderModel o) {
        final itemStatus = o.items.map((i) => i.status).where((s) => s != null).firstOrNull;
        return itemStatus?.toUpperCase() ?? o.status.toUpperCase();
      }

      state = state.copyWith(
        pendingOrders: all.where((o) => getStatus(o) == 'PENDING').toList(),
        acceptedOrders: all.where((o) => getStatus(o) == 'ACCEPTED').toList(),
        preparingOrders: all.where((o) => getStatus(o) == 'PREPARING').toList(),
        readyOrders: all.where((o) => getStatus(o) == 'READY_FOR_PICKUP').toList(),
        deliveredOrders: all.where((o) => const {'DELIVERED', 'COMPLETED'}.contains(getStatus(o))).toList(),
        cancelledOrders: all.where((o) => const {'CANCELLED', 'REJECTED'}.contains(getStatus(o))).toList(),
        isLoading: false,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    if (!_mounted) return false;
    try {
      await _ref.read(orderRepositoryProvider).updateOrderStatus(orderId, status);
      if (!_mounted) return false;
      state = state.copyWith(actionMessage: 'Order updated to $status');
      await loadOrders();
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

final farmerOrderProvider =
    StateNotifierProvider<FarmerOrderNotifier, FarmerOrderState>((ref) {
  return FarmerOrderNotifier(ref);
});
