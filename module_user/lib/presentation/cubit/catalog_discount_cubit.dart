import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/shared_domain/shared_usecases/get_discount_products_usecase.dart';
import 'catalog_discount_state.dart';

class CatalogDiscountCubit extends Cubit<CatalogDiscountState> {
  final GetDiscountProductsUseCase _getDiscountProductsUseCase;

  CatalogDiscountCubit(this._getDiscountProductsUseCase)
      : super(CatalogDiscountInitial());

  Future<void> fetchDiscountProducts({String? query}) async {
    emit(CatalogDiscountLoading());
    final result = await _getDiscountProductsUseCase(query: query);
    result.fold(
      (failure) => emit(CatalogDiscountError(failure.message)),
      (products) => emit(CatalogDiscountLoaded(products)),
    );
  }
}
