import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_user/domain/entities/cart_item.dart';
import 'package:module_user/presentation/bloc/cart_bloc.dart';

class CardCart extends StatelessWidget {
  final CartItem cartItem;

  const CardCart({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeftImage(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRightImage(),
                  const SizedBox(height: 8),
                  _buildItemDetails(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftImage() {
    
    final images = cartItem.imageUrls;
    final url = images.isNotEmpty ? images.first : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 120,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: _imageWidget(url),
        ),
      ),
    );
  }

  Widget _buildRightImage() {
    final images = cartItem.imageUrls;
    final url = images.length > 1 ? images[1] : '';

    if (url.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 80,
        width: double.infinity,
        child: _imageWidget(url),
      ),
    );
  }

  Widget _imageWidget(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error, color: Colors.grey),
      ),
    );
  }

  Widget _buildItemDetails(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cartItem.brandName.isNotEmpty ? cartItem.brandName : cartItem.productName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Size : ${cartItem.selectedSize}',
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'Rp ${cartItem.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (!isMobile) _buildQuantitySelector(context),
          ],
        ),
        if (isMobile) _buildQuantitySelector(context),
      ],
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (cartItem.quantity > 1) {
                context.read<CartBloc>().add(
                      UpdateCartQuantity(cartItem.id, cartItem.quantity - 1),
                    );
              } else {
                context.read<CartBloc>().add(RemoveFromCart(cartItem.id));
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '${cartItem.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () {
              context.read<CartBloc>().add(
                    UpdateCartQuantity(cartItem.id, cartItem.quantity + 1),
                  );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
