class OrderItemEntity {
  final String brandName;
  final num discountPercent;
  final num finalPriceIdr;
  final num finalPriceUsd;
  final num priceUsd;
  final String productId;
  final String productName;
  final int quantity;
  final String size;

  const OrderItemEntity({
    required this.brandName,
    required this.discountPercent,
    required this.finalPriceIdr,
    required this.finalPriceUsd,
    required this.priceUsd,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.size,
  });
}

class CustomerInfoEntity {
  final String address;
  final String city;
  final String email;
  final String name;
  final String phone;
  final String postalCode;

  const CustomerInfoEntity({
    required this.address,
    required this.city,
    required this.email,
    required this.name,
    required this.phone,
    required this.postalCode,
  });
}

class OrderHistoryEntity {
  final String orderId;
  final String userId;
  final String paymentMethod;
  final String redirectUrl;
  final String shippingArea;
  final num shippingCostIdr;
  final num shippingCostUsd;
  final String snapToken;
  final String status;
  final num subtotalIdr;
  final num subtotalUsd;
  final num totalIdr;
  final num totalUsd;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CustomerInfoEntity customer;
  final List<OrderItemEntity> items;

  const OrderHistoryEntity({
    required this.orderId,
    required this.userId,
    required this.paymentMethod,
    required this.redirectUrl,
    required this.shippingArea,
    required this.shippingCostIdr,
    required this.shippingCostUsd,
    required this.snapToken,
    required this.status,
    required this.subtotalIdr,
    required this.subtotalUsd,
    required this.totalIdr,
    required this.totalUsd,
    this.createdAt,
    this.updatedAt,
    required this.customer,
    required this.items,
  });
}
