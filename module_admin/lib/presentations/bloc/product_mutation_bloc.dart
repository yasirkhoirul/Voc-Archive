import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_admin/domain/usecases/update_product_usecase.dart';
import 'package:module_core/shared_domain/shared_entities/product.dart';
import 'package:module_core/shared_domain/shared_usecases/get_product_by_id.dart';
import '../../domain/entities/create_product_input.dart';
import '../../domain/usecases/create_product_usecase.dart';

part 'product_mutation_event.dart';
part 'product_mutation_state.dart';

class ProductMutationBloc
    extends Bloc<ProductMutationEvent, ProductMutationState> {
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUsecase _updateProductSubmitted;
  final GetProductById _getProductById;

  ProductMutationBloc(
    this._createProductUseCase,
    this._updateProductSubmitted,
    this._getProductById,
  ) : super(ProductMutationInitial()) {
    on<CreateProductSubmitted>(_onCreateProduct);
    on<GetProductByIdEvent>(_onGetProductById);
    on<UpdateProductSubmitted>(_onUpdateProduct);
  }

  Future<void> _onCreateProduct(
    CreateProductSubmitted event,
    Emitter<ProductMutationState> emit,
  ) async {
    emit(ProductMutationLoading());
    final result = await _createProductUseCase(event.input);
    result.fold(
      (failure) => emit(ProductMutationError(failure.message)),
      (_) => emit(ProductMutationSuccess()),
    );
  }

  Future<void> _onGetProductById(
    GetProductByIdEvent event,
    Emitter<ProductMutationState> emit,
  ) async {
    emit(ProductMutationLoading());
    final result = await _getProductById(event.productId);
    result.fold(
      (failure) => emit(ProductMutationError(failure.message)),
      (product) => emit(ProductMutationLoaded(product)),
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductSubmitted event,
    Emitter<ProductMutationState> emit,
  ) async {
    emit(ProductMutationLoading());
    final result = await _updateProductSubmitted(event.input);
    result.fold(
      (failure) => emit(ProductMutationError(failure.message)),
      (_) => emit(ProductMutationSuccess()),
    );
  }
}
