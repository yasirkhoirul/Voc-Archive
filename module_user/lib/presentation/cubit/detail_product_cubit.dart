import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_entities/product.dart';
import 'package:module_core/shared_domain/shared_usecases/get_product_by_id.dart';

part 'detail_product_state.dart';

class DetailProductCubit extends Cubit<DetailProductState> {
  final GetProductById _getProductById;

  DetailProductCubit(this._getProductById) : super(DetailProductInitial());

  Future<void> fetchProduct(String uid) async {
    emit(DetailProductLoading());
    final result = await _getProductById(uid);
    result.fold(
      (failure) => emit(DetailProductError(failure.message)),
      (product) => emit(DetailProductLoaded(product)),
    );
  }
}
