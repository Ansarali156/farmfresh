class InventoryModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double currentStock;
  final double reservedStock;
  final double lowStockThreshold;
  final String unit;
  final String status;

  InventoryModel({
    required this.id,
    required this.productId,
    this.productName = '',
    this.productImage = '',
    this.currentStock = 0,
    this.reservedStock = 0,
    this.lowStockThreshold = 10,
    this.unit = 'kg',
    this.status = 'IN_STOCK',
  });

  double get availableStock => currentStock - reservedStock;

  bool get isLowStock => currentStock <= lowStockThreshold && currentStock > 0;
  bool get isOutOfStock => currentStock <= 0;

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final images = product?['images'] as List?;

    return InventoryModel(
      id: json['id'] as String,
      productId: json['productId'] as String? ?? '',
      productName: product?['name'] as String? ?? '',
      productImage: images != null && images.isNotEmpty
          ? (images[0]['imageUrl'] as String? ?? '')
          : '',
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0,
      reservedStock: (json['reservedStock'] as num?)?.toDouble() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toDouble() ?? 10,
      unit: json['unit'] as String? ?? 'kg',
      status: json['status'] as String? ?? 'IN_STOCK',
    );
  }
}
