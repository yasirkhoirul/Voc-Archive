part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class SetExchangeRateSubmitted extends SettingsEvent {
  final double usdToIdr;

  const SetExchangeRateSubmitted(this.usdToIdr);

  @override
  List<Object?> get props => [usdToIdr];
}

class AddShippingRateSubmitted extends SettingsEvent {
  final String namaArea;
  final double harga;

  const AddShippingRateSubmitted(this.namaArea, this.harga);

  @override
  List<Object?> get props => [namaArea, harga];
}

class UpdateShippingRateSubmitted extends SettingsEvent {
  final String namaArea;
  final double harga;

  const UpdateShippingRateSubmitted(this.namaArea, this.harga);

  @override
  List<Object?> get props => [namaArea, harga];
}

class DeleteShippingRateSubmitted extends SettingsEvent {
  final String namaArea;

  const DeleteShippingRateSubmitted(this.namaArea);

  @override
  List<Object?> get props => [namaArea];
}
