part of 'product_mutation_bloc.dart';

sealed class ProductMutationEvent extends Equatable {
  const ProductMutationEvent();

  @override
  List<Object> get props => [];
}

class CreateProductSubmitted extends ProductMutationEvent {
  final CreateProductInput input;

  const CreateProductSubmitted(this.input);

  @override
  List<Object> get props => [input];
}
