import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_entities/product.dart';
import 'package:module_core/shared_domain/shared_usecases/get_all_products_usecase.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetAllProductsUseCase _getAllProductsUseCase;

  CatalogBloc(this._getAllProductsUseCase) : super(CatalogInitial()) {
    on<FetchCatalogProducts>((event, emit) async {
      emit(CatalogLoading());
      final result = await _getAllProductsUseCase();
      result.fold(
        (failure) => emit(CatalogError(failure.message)),
        (products) => emit(CatalogLoaded(products)),
      );
    });
  }
}
