import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>((event, emit) {
      final currentItems = List<CartItem>.from(state.items);
      // Check if item exists (same productId and same selectedSize)
      final existingIndex = currentItems.indexWhere(
        (i) =>
            i.productId == event.item.productId &&
            i.selectedSize == event.item.selectedSize,
      );

      if (existingIndex >= 0) {
        // Update quantity
        final existingItem = currentItems[existingIndex];
        currentItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + event.item.quantity,
        );
      } else {
        // Add new
        currentItems.add(event.item);
      }
      emit(state.copyWith(items: currentItems));
    });

    on<RemoveFromCart>((event, emit) {
      final currentItems = List<CartItem>.from(state.items);
      currentItems.removeWhere((i) => i.id == event.cartItemId);
      emit(state.copyWith(items: currentItems));
    });

    on<UpdateCartQuantity>((event, emit) {
      final currentItems = List<CartItem>.from(state.items);
      final index = currentItems.indexWhere((i) => i.id == event.cartItemId);
      if (index >= 0) {
        if (event.quantity > 0) {
          currentItems[index] = currentItems[index].copyWith(
            quantity: event.quantity,
          );
        } else {
          currentItems.removeAt(index);
        }
        emit(state.copyWith(items: currentItems));
      }
    });

    on<ClearCart>((event, emit) {
      emit(const CartState(items: []));
    });
  }
}
