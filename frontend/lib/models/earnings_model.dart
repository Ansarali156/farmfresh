import '../core/utils/helpers.dart';

class EarningsModel {
  final double walletBalance;
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double dailyEarnings;
  final double pendingWithdrawals;
  final double completedWithdrawals;

  const EarningsModel({
    this.walletBalance = 0,
    this.totalEarnings = 0,
    this.monthlyEarnings = 0,
    this.weeklyEarnings = 0,
    this.dailyEarnings = 0,
    this.pendingWithdrawals = 0,
    this.completedWithdrawals = 0,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final total = (json['totalEarnings'] as num?)?.toDouble() ?? 0;
    final pending = (json['pendingWithdrawals'] as num?)?.toDouble() ?? 0;
    final completed = (json['completedWithdrawals'] as num?)?.toDouble() ?? 0;
    final rawBalance = total - pending - completed;

    return EarningsModel(
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? (rawBalance < 0 ? 0 : rawBalance),
      totalEarnings: total,
      monthlyEarnings: (json['monthlyEarnings'] as num?)?.toDouble() ?? 0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0,
      dailyEarnings: (json['dailyEarnings'] as num?)?.toDouble() ?? 0,
      pendingWithdrawals: pending,
      completedWithdrawals: completed,
    );
  }
}

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? orderId;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    this.orderId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'CREDIT',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'COMPLETED',
      createdAt: Helpers.toIst(DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now()),
      orderId: json['orderId'] as String?,
    );
  }
}
