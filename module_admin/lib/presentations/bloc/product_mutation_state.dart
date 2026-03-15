part of 'product_mutation_bloc.dart';

sealed class ProductMutationState extends Equatable {
  const ProductMutationState();
  
  @override
  List<Object> get props => [];
}

final class ProductMutationInitial extends ProductMutationState {}

final class ProductMutationLoading extends ProductMutationState {}

final class ProductMutationSuccess extends ProductMutationState {}

final class ProductMutationError extends ProductMutationState {
  final String message;

  const ProductMutationError(this.message);

  @override
  List<Object> get props => [message];
}
