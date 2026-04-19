import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/module_core.dart';
import '../../domain/usecases/set_exchange_rate_usecase.dart';
import '../../domain/usecases/add_shipping_rate_usecase.dart';
import '../../domain/usecases/update_shipping_rate_usecase.dart';
import '../../domain/usecases/delete_shipping_rate_usecase.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetExchangeRateUsecase _getExchangeRate;
  final SetExchangeRateUsecase _setExchangeRate;
  final GetShippingRatesUsecase _getShippingRates;
  final AddShippingRateUsecase _addShippingRate;
  final UpdateShippingRateUsecase _updateShippingRate;
  final DeleteShippingRateUsecase _deleteShippingRate;

  SettingsBloc(
    this._getExchangeRate,
    this._setExchangeRate,
    this._getShippingRates,
    this._addShippingRate,
    this._updateShippingRate,
    this._deleteShippingRate,
  ) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SetExchangeRateSubmitted>(_onSetExchangeRate);
    on<AddShippingRateSubmitted>(_onAddShippingRate);
    on<UpdateShippingRateSubmitted>(_onUpdateShippingRate);
    on<DeleteShippingRateSubmitted>(_onDeleteShippingRate);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    final exchangeResult = await _getExchangeRate();
    final shippingResult = await _getShippingRates();

    double? exchangeRate;
    List<Map<String, dynamic>> shippingRates = [];
    String? error;

    exchangeResult.fold(
      (failure) => error = failure.message,
      (rate) => exchangeRate = rate,
    );

    shippingResult.fold(
      (failure) => error = failure.message,
      (rates) => shippingRates = rates,
    );

    emit(
      state.copyWith(
        status: error != null ? SettingsStatus.error : SettingsStatus.loaded,
        exchangeRate: exchangeRate,
        shippingRates: shippingRates,
        errorMessage: error,
      ),
    );
  }

  Future<void> _onSetExchangeRate(
    SetExchangeRateSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.mutating));
    final result = await _setExchangeRate(event.usdToIdr);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            status: SettingsStatus.mutationSuccess,
            exchangeRate: event.usdToIdr,
            successMessage: 'Exchange rate berhasil diupdate',
          ),
        );
      },
    );
  }

  Future<void> _onAddShippingRate(
    AddShippingRateSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.mutating));
    final result = await _addShippingRate(event.namaArea, event.harga);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: SettingsStatus.mutationSuccess,
          successMessage: 'Shipping rate "${event.namaArea}" berhasil ditambah',
        ),
      ),
    );
    // Reload data
    add(LoadSettings());
  }

  Future<void> _onUpdateShippingRate(
    UpdateShippingRateSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.mutating));
    final result = await _updateShippingRate(event.namaArea, event.harga);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: SettingsStatus.mutationSuccess,
          successMessage: 'Shipping rate "${event.namaArea}" berhasil diupdate',
        ),
      ),
    );
    add(LoadSettings());
  }

  Future<void> _onDeleteShippingRate(
    DeleteShippingRateSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.mutating));
    final result = await _deleteShippingRate(event.namaArea);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: SettingsStatus.mutationSuccess,
          successMessage: 'Shipping rate "${event.namaArea}" berhasil dihapus',
        ),
      ),
    );
    add(LoadSettings());
  }
}
