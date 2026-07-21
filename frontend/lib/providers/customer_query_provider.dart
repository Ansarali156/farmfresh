import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_query_model.dart';

class CustomerQueryState {
  final List<CustomerQueryModel> queries;
  final bool isLoading;
  final String? errorMessage;

  CustomerQueryState({
    this.queries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CustomerQueryState copyWith({
    List<CustomerQueryModel>? queries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerQueryState(
      queries: queries ?? this.queries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CustomerQueryNotifier extends StateNotifier<CustomerQueryState> {
  CustomerQueryNotifier() : super(CustomerQueryState()) {
    _loadInitialQueries();
  }

  void _loadInitialQueries() {
    // Seed initial demo queries for smooth UX
    final sampleQueries = [
      CustomerQueryModel(
        id: 'TICK-1001',
        subject: 'Delivery Delay Inquiry',
        category: 'Delivery Issue',
        description: 'Asking about estimated delivery time for my recent organic vegetable order.',
        status: 'RESOLVED',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        orderId: 'ORD-9821',
      ),
      CustomerQueryModel(
        id: 'TICK-1002',
        subject: 'Packaging Quality Feedback',
        category: 'Product Quality',
        description: 'Requesting insulated packaging for dairy milk products in hot weather.',
        status: 'OPEN',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
    state = state.copyWith(queries: sampleQueries);
  }

  Future<bool> submitQuery({
    required String subject,
    required String category,
    required String description,
    String? orderId,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final newQuery = CustomerQueryModel(
      id: 'TICK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      subject: subject,
      category: category,
      description: description,
      status: 'OPEN',
      createdAt: DateTime.now(),
      orderId: orderId,
    );

    state = state.copyWith(
      isLoading: false,
      queries: [newQuery, ...state.queries],
    );
    return true;
  }
}

final customerQueryProvider =
    StateNotifierProvider<CustomerQueryNotifier, CustomerQueryState>((ref) {
  return CustomerQueryNotifier();
});
