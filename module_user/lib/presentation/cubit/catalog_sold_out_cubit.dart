import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/shared_domain/shared_usecases/get_all_products_usecase.dart';
import 'catalog_sold_out_state.dart';

class CatalogSoldOutCubit extends Cubit<CatalogSoldOutState> {
  final GetAllProductsUseCase _getAllProductsUseCase;

  CatalogSoldOutCubit(this._getAllProductsUseCase)
    : super(CatalogSoldOutInitial());

  Future<void> fetchSoldOutProducts({String? query}) async {
    emit(CatalogSoldOutLoading());
    final result = await _getAllProductsUseCase(query: query);
    result.fold((failure) => emit(CatalogSoldOutError(failure.message)), (
      products,
    ) {
      final soldoutProducts = products.where((p) => p.totalStok == 0).toList();
      emit(CatalogSoldOutLoaded(soldoutProducts));
    });
  }
}
