// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      brandName: json['brand_name'] as String,
      discountPercent: json['discount_percent'] as num? ?? 0,
      finalPriceIdr: json['final_price_idr'] as num,
      finalPriceUsd: json['final_price_usd'] as num,
      priceUsd: json['price_usd'] as num,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      size: json['size'] as String,
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'brand_name': instance.brandName,
      'discount_percent': instance.discountPercent,
      'final_price_idr': instance.finalPriceIdr,
      'final_price_usd': instance.finalPriceUsd,
      'price_usd': instance.priceUsd,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'quantity': instance.quantity,
      'size': instance.size,
    };

CustomerInfoModel _$CustomerInfoModelFromJson(Map<String, dynamic> json) =>
    CustomerInfoModel(
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
    );

Map<String, dynamic> _$CustomerInfoModelToJson(CustomerInfoModel instance) =>
    <String, dynamic>{
      'address': instance.address,
      'city': instance.city,
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'postal_code': instance.postalCode,
    };

OrderHistoryModel _$OrderHistoryModelFromJson(
  Map<String, dynamic> json,
) => OrderHistoryModel(
  orderId: json['order_id'] as String,
  userId: json['user_id'] as String,
  paymentMethod: json['payment_method'] as String? ?? '',
  redirectUrl: json['redirect_url'] as String? ?? '',
  shippingArea: json['shipping_area'] as String? ?? '',
  shippingCostIdr: json['shipping_cost_idr'] as num? ?? 0,
  shippingCostUsd: json['shipping_cost_usd'] as num? ?? 0,
  snapToken: json['snap_token'] as String? ?? '',
  status: json['status'] as String? ?? 'pending',
  subtotalIdr: json['subtotal_idr'] as num? ?? 0,
  subtotalUsd: json['subtotal_usd'] as num? ?? 0,
  totalIdr: json['total_idr'] as num? ?? 0,
  totalUsd: json['total_usd'] as num? ?? 0,
  exchangeRate: json['exchange_rate'] as num? ?? 0,
  proofUrl: json['proof_url'] as String? ?? '',
  createdAt: const NullableTimestampConverter().fromJson(json['created_at']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updated_at']),
  customerInfo: CustomerInfoModel.fromJson(
    json['customer'] as Map<String, dynamic>,
  ),
  orderItems: (json['items'] as List<dynamic>)
      .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderHistoryModelToJson(
  OrderHistoryModel instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'user_id': instance.userId,
  'payment_method': instance.paymentMethod,
  'redirect_url': instance.redirectUrl,
  'shipping_area': instance.shippingArea,
  'shipping_cost_idr': instance.shippingCostIdr,
  'shipping_cost_usd': instance.shippingCostUsd,
  'snap_token': instance.snapToken,
  'status': instance.status,
  'subtotal_idr': instance.subtotalIdr,
  'subtotal_usd': instance.subtotalUsd,
  'total_idr': instance.totalIdr,
  'total_usd': instance.totalUsd,
  'exchange_rate': instance.exchangeRate,
  'proof_url': instance.proofUrl,
  'created_at': const NullableTimestampConverter().toJson(instance.createdAt),
  'updated_at': const NullableTimestampConverter().toJson(instance.updatedAt),
  'customer': instance.customerInfo.toJson(),
  'items': instance.orderItems.map((e) => e.toJson()).toList(),
};
