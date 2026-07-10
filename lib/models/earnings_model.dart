class EarningsModel {
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double dailyEarnings;
  final double pendingWithdrawals;
  final double completedWithdrawals;

  EarningsModel({
    this.totalEarnings = 0,
    this.monthlyEarnings = 0,
    this.weeklyEarnings = 0,
    this.dailyEarnings = 0,
    this.pendingWithdrawals = 0,
    this.completedWithdrawals = 0,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      monthlyEarnings: (json['monthlyEarnings'] as num?)?.toDouble() ?? 0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0,
      dailyEarnings: (json['dailyEarnings'] as num?)?.toDouble() ?? 0,
      pendingWithdrawals: (json['pendingWithdrawals'] as num?)?.toDouble() ?? 0,
      completedWithdrawals: (json['completedWithdrawals'] as num?)?.toDouble() ?? 0,
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
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      orderId: json['orderId'] as String?,
    );
  }
}
