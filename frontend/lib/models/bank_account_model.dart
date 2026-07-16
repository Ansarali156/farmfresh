class BankAccountModel {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String? routingNumber;
  final bool isVerified;

  BankAccountModel({
    required this.id,
    this.bankName = '',
    this.accountNumber = '',
    this.accountHolder = '',
    this.routingNumber,
    this.isVerified = false,
  });

  String get maskedAccount {
    if (accountNumber.length <= 4) return accountNumber;
    return '**** ${accountNumber.substring(accountNumber.length - 4)}';
  }

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountHolder: json['accountHolder'] as String? ?? '',
      routingNumber: json['routingNumber'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
      if (routingNumber != null) 'routingNumber': routingNumber,
    };
  }
}
