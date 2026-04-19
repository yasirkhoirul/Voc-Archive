import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String brandName;
  final List<String> imageUrls;
  final String selectedSize;
  final double price;
  final int quantity;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.imageUrls,
    required this.selectedSize,
    required this.price,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? brandName,
    List<String>? imageUrls,
    String? selectedSize,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      brandName: brandName ?? this.brandName,
      imageUrls: imageUrls ?? this.imageUrls,
      selectedSize: selectedSize ?? this.selectedSize,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    brandName,
    imageUrls,
    selectedSize,
    price,
    quantity,
  ];
}
