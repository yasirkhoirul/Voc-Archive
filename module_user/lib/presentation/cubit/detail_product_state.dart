part of 'detail_product_cubit.dart';

sealed class DetailProductState extends Equatable {
  const DetailProductState();

  @override
  List<Object> get props => [];
}

final class DetailProductInitial extends DetailProductState {}

final class DetailProductLoading extends DetailProductState {}

final class DetailProductLoaded extends DetailProductState {
  final Product product;
  const DetailProductLoaded(this.product);

  @override
  List<Object> get props => [product];
}

final class DetailProductError extends DetailProductState {
  final String message;
  const DetailProductError(this.message);

  @override
  List<Object> get props => [message];
}
