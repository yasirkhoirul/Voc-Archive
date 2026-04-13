part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}
class AddToCart extends CartEvent {
  final CartItem item;

  const AddToCart(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;

  const RemoveFromCart(this.cartItemId);

  @override
  List<Object> get props => [cartItemId];
}

class UpdateCartQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartQuantity(this.cartItemId, this.quantity);

  @override
  List<Object> get props => [cartItemId, quantity];
}

class ClearCart extends CartEvent {}
