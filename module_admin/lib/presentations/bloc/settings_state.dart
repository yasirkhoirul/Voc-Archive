part of 'settings_bloc.dart';

enum SettingsStatus {
  initial,
  loading,
  loaded,
  mutating,
  mutationSuccess,
  error,
}

class SettingsState extends Equatable {
  final SettingsStatus status;
  final double? exchangeRate;
  final List<Map<String, dynamic>> shippingRates;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.exchangeRate,
    this.shippingRates = const [],
    this.errorMessage,
    this.successMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    double? exchangeRate,
    List<Map<String, dynamic>>? shippingRates,
    String? errorMessage,
    String? successMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      shippingRates: shippingRates ?? this.shippingRates,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        exchangeRate,
        shippingRates,
        errorMessage,
        successMessage,
      ];
}
