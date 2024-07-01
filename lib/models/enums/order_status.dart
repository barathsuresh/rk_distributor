enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return '';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status) {
      case 'Pending':
        return OrderStatus.pending;
      case 'Processing':
        return OrderStatus.processing;
      case 'Shipped':
        return OrderStatus.shipped;
      case 'Delivered':
        return OrderStatus.delivered;
      case 'Cancelled':
        return OrderStatus.cancelled;
      default:
        throw ArgumentError('Unknown order status: $status');
    }
  }
}
