class CustomerQueryModel {
  final String id;
  final String subject;
  final String category;
  final String description;
  final String status; // 'OPEN', 'IN_PROGRESS', 'RESOLVED'
  final DateTime createdAt;
  final String? orderId;

  CustomerQueryModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.orderId,
  });

  factory CustomerQueryModel.fromJson(Map<String, dynamic> json) {
    return CustomerQueryModel(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? 'General Query',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      orderId: json['orderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'category': category,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (orderId != null) 'orderId': orderId,
    };
  }
}
