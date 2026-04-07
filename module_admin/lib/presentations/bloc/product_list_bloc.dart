import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/module_core.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final GetAllProductsUseCase _getAllProductsUseCase;

  ProductListBloc(this._getAllProductsUseCase) : super(ProductListInitial()) {
    on<FetchAllProducts>((event, emit) async {
      emit(ProductListLoading());
      final result = await _getAllProductsUseCase();
      result.fold(
        (failure) => emit(ProductListError(failure.message)),
        (products) => emit(ProductListLoaded(products)),
      );
    });
  }
}
