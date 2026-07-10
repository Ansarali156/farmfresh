/// All enums that mirror the backend Prisma schema enums.
/// These MUST stay in sync with backend/prisma/schema.prisma

enum UserRole {
  customer,
  farmer,
  deliveryPartner,
  admin;

  String get apiValue {
    switch (this) {
      case UserRole.customer:
        return 'CUSTOMER';
      case UserRole.farmer:
        return 'FARMER';
      case UserRole.deliveryPartner:
        return 'DELIVERY_PARTNER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  static UserRole fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'FARMER':
        return UserRole.farmer;
      case 'DELIVERY_PARTNER':
        return UserRole.deliveryPartner;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  accepted,
  rejected,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled,
  completed;

  String get apiValue {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.accepted:
        return 'ACCEPTED';
      case OrderStatus.rejected:
        return 'REJECTED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.readyForPickup:
        return 'READY_FOR_PICKUP';
      case OrderStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
      case OrderStatus.completed:
        return 'COMPLETED';
    }
  }

  static OrderStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'ACCEPTED':
        return OrderStatus.accepted;
      case 'REJECTED':
        return OrderStatus.rejected;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY_FOR_PICKUP':
        return OrderStatus.readyForPickup;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      case 'COMPLETED':
        return OrderStatus.completed;
      default:
        return OrderStatus.pending;
    }
  }

  /// Display-friendly name for UI.
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
      case OrderStatus.accepted:
      case OrderStatus.preparing:
      case OrderStatus.readyForPickup:
        return 'Accepted';
      case OrderStatus.outForDelivery:
        return 'In Transit';
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return 'Delivered';
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded;

  String get apiValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.completed:
        return 'COMPLETED';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.refunded:
        return 'REFUNDED';
    }
  }

  static PaymentStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'COMPLETED':
        return PaymentStatus.completed;
      case 'FAILED':
        return PaymentStatus.failed;
      case 'REFUNDED':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

enum DeliveryStatus {
  pendingAssignment,
  assigned,
  accepted,
  rejected,
  headingToPickup,
  pickedUp,
  outForDelivery,
  delivered,
  cancelled;

  String get apiValue {
    switch (this) {
      case DeliveryStatus.pendingAssignment:
        return 'PENDING_ASSIGNMENT';
      case DeliveryStatus.assigned:
        return 'ASSIGNED';
      case DeliveryStatus.accepted:
        return 'ACCEPTED';
      case DeliveryStatus.rejected:
        return 'REJECTED';
      case DeliveryStatus.headingToPickup:
        return 'HEADING_TO_PICKUP';
      case DeliveryStatus.pickedUp:
        return 'PICKED_UP';
      case DeliveryStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case DeliveryStatus.delivered:
        return 'DELIVERED';
      case DeliveryStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static DeliveryStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'ASSIGNED':
        return DeliveryStatus.assigned;
      case 'ACCEPTED':
        return DeliveryStatus.accepted;
      case 'REJECTED':
        return DeliveryStatus.rejected;
      case 'HEADING_TO_PICKUP':
        return DeliveryStatus.headingToPickup;
      case 'PICKED_UP':
        return DeliveryStatus.pickedUp;
      case 'OUT_FOR_DELIVERY':
        return DeliveryStatus.outForDelivery;
      case 'DELIVERED':
        return DeliveryStatus.delivered;
      case 'CANCELLED':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pendingAssignment;
    }
  }
}

enum ProductStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  outOfStock,
  archived;

  String get apiValue {
    switch (this) {
      case ProductStatus.draft:
        return 'DRAFT';
      case ProductStatus.pendingApproval:
        return 'PENDING_APPROVAL';
      case ProductStatus.approved:
        return 'APPROVED';
      case ProductStatus.rejected:
        return 'REJECTED';
      case ProductStatus.outOfStock:
        return 'OUT_OF_STOCK';
      case ProductStatus.archived:
        return 'ARCHIVED';
    }
  }

  static ProductStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING_APPROVAL':
        return ProductStatus.pendingApproval;
      case 'APPROVED':
        return ProductStatus.approved;
      case 'REJECTED':
        return ProductStatus.rejected;
      case 'OUT_OF_STOCK':
        return ProductStatus.outOfStock;
      case 'ARCHIVED':
        return ProductStatus.archived;
      default:
        return ProductStatus.draft;
    }
  }
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
  discontinued;

  String get apiValue {
    switch (this) {
      case StockStatus.inStock:
        return 'IN_STOCK';
      case StockStatus.lowStock:
        return 'LOW_STOCK';
      case StockStatus.outOfStock:
        return 'OUT_OF_STOCK';
      case StockStatus.discontinued:
        return 'DISCONTINUED';
    }
  }

  static StockStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'LOW_STOCK':
        return StockStatus.lowStock;
      case 'OUT_OF_STOCK':
        return StockStatus.outOfStock;
      case 'DISCONTINUED':
        return StockStatus.discontinued;
      default:
        return StockStatus.inStock;
    }
  }
}
