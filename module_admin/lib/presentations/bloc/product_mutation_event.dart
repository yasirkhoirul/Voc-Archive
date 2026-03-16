part of 'product_mutation_bloc.dart';

sealed class ProductMutationEvent extends Equatable {
  const ProductMutationEvent();

  @override
  List<Object> get props => [];
}

class GetProductByIdEvent extends ProductMutationEvent {
  final String productId;

  const GetProductByIdEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class UpdateProductSubmitted extends ProductMutationEvent {
  final CreateProductInput input;

  const UpdateProductSubmitted(this.input);

  @override
  List<Object> get props => [input];
}

class CreateProductSubmitted extends ProductMutationEvent {
  final CreateProductInput input;

  const CreateProductSubmitted(this.input);

  @override
  List<Object> get props => [input];
}
