import 'package:json_annotation/json_annotation.dart';
import '../../shared_domain/shared_entities/order_history.dart';
import 'timestamp_converter.dart';

part 'order_history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    @JsonKey(name: 'brand_name') required super.brandName,
    @JsonKey(name: 'discount_percent', defaultValue: 0) required super.discountPercent,
    @JsonKey(name: 'final_price_idr') required super.finalPriceIdr,
    @JsonKey(name: 'final_price_usd') required super.finalPriceUsd,
    @JsonKey(name: 'price_usd') required super.priceUsd,
    @JsonKey(name: 'product_id') required super.productId,
    @JsonKey(name: 'product_name') required super.productName,
    required super.quantity,
    required super.size,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CustomerInfoModel extends CustomerInfoEntity {
  const CustomerInfoModel({
    @JsonKey(defaultValue: '') required super.address,
    @JsonKey(defaultValue: '') required super.city,
    @JsonKey(defaultValue: '') required super.email,
    @JsonKey(defaultValue: '') required super.name,
    @JsonKey(defaultValue: '') required super.phone,
    @JsonKey(name: 'postal_code', defaultValue: '') required super.postalCode,
  });

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerInfoModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
@NullableTimestampConverter()
class OrderHistoryModel extends OrderHistoryEntity {
  const OrderHistoryModel({
    @JsonKey(name: 'order_id') required super.orderId,
    @JsonKey(name: 'user_id') required super.userId,
    @JsonKey(name: 'payment_method', defaultValue: '') required super.paymentMethod,
    @JsonKey(name: 'redirect_url', defaultValue: '') required super.redirectUrl,
    @JsonKey(name: 'shipping_area', defaultValue: '') required super.shippingArea,
    @JsonKey(name: 'shipping_cost_idr', defaultValue: 0) required super.shippingCostIdr,
    @JsonKey(name: 'shipping_cost_usd', defaultValue: 0) required super.shippingCostUsd,
    @JsonKey(name: 'snap_token', defaultValue: '') required super.snapToken,
    @JsonKey(defaultValue: 'pending') required super.status,
    @JsonKey(name: 'subtotal_idr', defaultValue: 0) required super.subtotalIdr,
    @JsonKey(name: 'subtotal_usd', defaultValue: 0) required super.subtotalUsd,
    @JsonKey(name: 'total_idr', defaultValue: 0) required super.totalIdr,
    @JsonKey(name: 'total_usd', defaultValue: 0) required super.totalUsd,
    @NullableTimestampConverter() @JsonKey(name: 'created_at') super.createdAt,
    @NullableTimestampConverter() @JsonKey(name: 'updated_at') super.updatedAt,
    required CustomerInfoModel customerInfo,
    required List<OrderItemModel> orderItems,
  }) : super(
          customer: customerInfo,
          items: orderItems,
        );

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryModelToJson(this);

  // Helper overrides for serialization of subclass instances
  @JsonKey(name: 'customer')
  CustomerInfoModel get customerInfo => customer as CustomerInfoModel;

  @JsonKey(name: 'items')
  List<OrderItemModel> get orderItems =>
      items.cast<OrderItemModel>().toList();
}
