class WithdrawalModel {
  final String id;
  final double amount;
  final String status;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final String? reason;
  final DateTime createdAt;
  final DateTime? processedAt;

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.status,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.reason,
    required this.createdAt,
    this.processedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    final bankAccount = json['bankAccount'] as Map<String, dynamic>?;
    return WithdrawalModel(
      id: json['id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      bankName: bankAccount?['bankName'] as String? ?? json['bankName'] as String?,
      accountNumber: bankAccount?['accountNumber'] as String? ?? json['accountNumber'] as String?,
      accountHolder: bankAccount?['accountHolder'] as String? ?? json['accountHolder'] as String?,
      reason: json['reason'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'] as String)
          : null,
    );
  }
}
