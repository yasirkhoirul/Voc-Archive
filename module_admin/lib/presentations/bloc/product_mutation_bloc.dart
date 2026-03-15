import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/create_product_input.dart';
import '../../domain/usecases/create_product_usecase.dart';

part 'product_mutation_event.dart';
part 'product_mutation_state.dart';

class ProductMutationBloc extends Bloc<ProductMutationEvent, ProductMutationState> {
  final CreateProductUseCase _createProductUseCase;

  ProductMutationBloc(this._createProductUseCase) : super(ProductMutationInitial()) {
    on<CreateProductSubmitted>(_onCreateProduct);
  }

  Future<void> _onCreateProduct(CreateProductSubmitted event, Emitter<ProductMutationState> emit) async {
    emit(ProductMutationLoading());
    final result = await _createProductUseCase(event.input);
    result.fold(
      (failure) => emit(ProductMutationError(failure.message)),
      (_) => emit(ProductMutationSuccess()),
    );
  }
}
