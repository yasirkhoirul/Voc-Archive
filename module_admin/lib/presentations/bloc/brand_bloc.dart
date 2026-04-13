import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/module_core.dart';
import '../../domain/usecases/create_brand_usecase.dart';
import '../../domain/usecases/update_brand_usecase.dart';
import '../../domain/usecases/delete_brand_usecase.dart';

part 'brand_event.dart';
part 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  final GetBrandsUsecase _getBrands;
  final CreateBrandUsecase _createBrand;
  final UpdateBrandUsecase _updateBrand;
  final DeleteBrandUsecase _deleteBrand;

  BrandBloc(
    this._getBrands,
    this._createBrand,
    this._updateBrand,
    this._deleteBrand,
  ) : super(const BrandState()) {
    on<LoadBrands>(_onLoadBrands);
    on<CreateBrandSubmitted>(_onCreateBrand);
    on<UpdateBrandSubmitted>(_onUpdateBrand);
    on<DeleteBrandSubmitted>(_onDeleteBrand);
  }

  Future<void> _onLoadBrands(
    LoadBrands event,
    Emitter<BrandState> emit,
  ) async {
    emit(state.copyWith(status: BrandStatus.loading));
    final result = await _getBrands();
    result.fold(
      (failure) => emit(state.copyWith(
        status: BrandStatus.error,
        errorMessage: failure.message,
      )),
      (brands) => emit(state.copyWith(
        status: BrandStatus.loaded,
        brands: brands,
      )),
    );
  }

  Future<void> _onCreateBrand(
    CreateBrandSubmitted event,
    Emitter<BrandState> emit,
  ) async {
    emit(state.copyWith(status: BrandStatus.mutating));
    final result = await _createBrand(event.nama);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BrandStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: BrandStatus.mutationSuccess,
        successMessage: 'Brand "${event.nama}" berhasil ditambah',
      )),
    );
    add(LoadBrands());
  }

  Future<void> _onUpdateBrand(
    UpdateBrandSubmitted event,
    Emitter<BrandState> emit,
  ) async {
    emit(state.copyWith(status: BrandStatus.mutating));
    final result = await _updateBrand(event.uid, event.nama);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BrandStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: BrandStatus.mutationSuccess,
        successMessage: 'Brand berhasil diupdate',
      )),
    );
    add(LoadBrands());
  }

  Future<void> _onDeleteBrand(
    DeleteBrandSubmitted event,
    Emitter<BrandState> emit,
  ) async {
    emit(state.copyWith(status: BrandStatus.mutating));
    final result = await _deleteBrand(event.uid);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BrandStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: BrandStatus.mutationSuccess,
        successMessage: 'Brand berhasil dihapus',
      )),
    );
    add(LoadBrands());
  }
}
