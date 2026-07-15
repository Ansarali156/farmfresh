import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'app_providers.dart';

class OrderState {
  final List<OrderModel> currentOrders;
  final List<OrderModel> historyOrders;
  final OrderModel? selectedOrder;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreHistory;
  final int currentPage;
  final String? errorMessage;
  final String? actionMessage;

  OrderState({
    this.currentOrders = const [],
    this.historyOrders = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreHistory = true,
    this.currentPage = 1,
    this.errorMessage,
    this.actionMessage,
  });

  OrderState copyWith({
    List<OrderModel>? currentOrders,
    List<OrderModel>? historyOrders,
    OrderModel? selectedOrder,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreHistory,
    int? currentPage,
    String? errorMessage,
    String? actionMessage,
  }) {
    return OrderState(
      currentOrders: currentOrders ?? this.currentOrders,
      historyOrders: historyOrders ?? this.historyOrders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;
  bool _mounted = true;

  OrderNotifier(this._ref) : super(OrderState()) {
    loadOrders();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  static const _activeStatuses = {
    'PENDING',
    'CONFIRMED',
    'ACCEPTED',
    'PREPARING',
    'READY_FOR_PICKUP',
    'OUT_FOR_DELIVERY',
  };

  Future<void> loadOrders() async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final allOrders =
          await _ref.read(orderRepositoryProvider).getCustomerOrders(
                page: 1,
                limit: 50,
              );

      if (!_mounted) return;

      final current = allOrders
          .where((o) => _activeStatuses.contains(o.status.toUpperCase()))
          .toList();
      final history = allOrders
          .where((o) => !_activeStatuses.contains(o.status.toUpperCase()))
          .toList();

      state = state.copyWith(
        currentOrders: current,
        historyOrders: history,
        isLoading: false,
        currentPage: 1,
        hasMoreHistory: history.length >= 10,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMoreHistory() async {
    if (!_mounted || state.isLoadingMore || !state.hasMoreHistory) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final moreOrders =
          await _ref.read(orderRepositoryProvider).getCustomerOrders(
                page: nextPage,
                limit: 10,
              );

      if (!_mounted) return;

      if (moreOrders.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMoreHistory: false);
        return;
      }

      final newHistory = [...state.historyOrders, ...moreOrders];
      state = state.copyWith(
        historyOrders: newHistory,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMoreHistory: moreOrders.length >= 10,
      );
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> loadOrderById(String orderId) async {
    if (!_mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final order =
          await _ref.read(orderRepositoryProvider).getOrderById(orderId);
      if (!_mounted) return;
      state = state.copyWith(selectedOrder: order, isLoading: false);
    } catch (e) {
      if (!_mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<OrderModel?> createOrder({
    required List<CartItemModel> items,
    required double total,
    required double deliveryFee,
    String? address,
    String? notes,
  }) async {
    if (!_mounted) return null;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newOrder = OrderModel(
        id: '',
        orderNumber: '',
        date: DateTime.now(),
        items: items,
        total: total,
        deliveryFee: deliveryFee,
        status: 'PENDING',
      );
      final created = await _ref.read(orderRepositoryProvider).createOrder(
            newOrder,
            address: address,
            notes: notes,
          );
      await loadOrders();
      return created;
    } catch (e) {
      if (!_mounted) return null;
      state = state.copyWith(
          isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> updateStatus(String orderId, String status) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(orderId, status);
      await loadOrders();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(
          isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref
          .read(orderRepositoryProvider)
          .cancelOrder(orderId, reason: reason);
      if (!_mounted) return false;
      state = state.copyWith(
        isLoading: false,
        actionMessage: 'Order cancelled successfully',
      );
      await loadOrders();
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(
          isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> reorder(String orderId) async {
    if (!_mounted) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(orderRepositoryProvider).reorder(orderId);
      if (!_mounted) return false;
      state = state.copyWith(
        isLoading: false,
        actionMessage: 'Items added to cart successfully',
      );
      return true;
    } catch (e) {
      if (!_mounted) return false;
      state = state.copyWith(
          isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    if (!_mounted) return;
    state = state.copyWith(errorMessage: null, actionMessage: null);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});
