import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../enums/currency_enum.dart';

class CurrencyState {
  final CurrencyType currencyType;
  final double exchangeRate;

  const CurrencyState({
    this.currencyType = CurrencyType.usd,
    this.exchangeRate = 0,
  });

  CurrencyState copyWith({
    CurrencyType? currencyType,
    double? exchangeRate,
  }) {
    return CurrencyState(
      currencyType: currencyType ?? this.currencyType,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }
}

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit() : super(const CurrencyState());

  /// Set the exchange rate from Firestore (called on app startup).
  void setExchangeRate(double rate) {
    emit(state.copyWith(exchangeRate: rate));
  }

  void toggleCurrency() {
    final newType = state.currencyType == CurrencyType.idr
        ? CurrencyType.usd
        : CurrencyType.idr;
    emit(state.copyWith(currencyType: newType));
  }

  void setCurrency(CurrencyType type) {
    emit(state.copyWith(currencyType: type));
  }

  /// Formats a USD amount based on the selected currency.
  /// [amountUsd] is the price in USD.
  String format(num amountUsd) {
    if (state.currencyType == CurrencyType.usd) {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      ).format(amountUsd);
    } else {
      // Convert USD to IDR using the dynamic exchange rate
      final amountIdr = amountUsd * state.exchangeRate;
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amountIdr);
    }
  }

  /// Returns the current currency type.
  CurrencyType get currencyType => state.currencyType;

  /// Returns the current exchange rate.
  double get exchangeRate => state.exchangeRate;
}
