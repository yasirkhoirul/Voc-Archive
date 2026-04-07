part of 'product_list_bloc.dart';

sealed class ProductListState extends Equatable {
  const ProductListState();
  
  @override
  List<Object> get props => [];
}

final class ProductListInitial extends ProductListState {}

final class ProductListLoading extends ProductListState {}

final class ProductListLoaded extends ProductListState {
  final List<Product> products;

  const ProductListLoaded(this.products);

  @override
  List<Object> get props => [products];
}

final class ProductListError extends ProductListState {
  final String message;

  const ProductListError(this.message);

  @override
  List<Object> get props => [message];
}
