part of 'product_mutation_bloc.dart';

sealed class ProductMutationState extends Equatable {
  const ProductMutationState();
  
  @override
  List<Object> get props => [];
}

final class ProductMutationInitial extends ProductMutationState {}
final class ProductMutationLoaded extends ProductMutationState {
  final Product product;

  const ProductMutationLoaded(this.product);

  @override
  List<Object> get props => [product];
}

final class ProductMutationLoading extends ProductMutationState {}

final class ProductMutationSuccess extends ProductMutationState {}

final class ProductMutationError extends ProductMutationState {
  final String message;

  const ProductMutationError(this.message);

  @override
  List<Object> get props => [message];
}

final class ProductFormLoaded extends ProductMutationState {
  final Product? product;
  final List<Map<String, dynamic>> brands;

  const ProductFormLoaded({this.product, required this.brands});

  @override
  List<Object> get props => [if (product != null) product!, brands];
}
