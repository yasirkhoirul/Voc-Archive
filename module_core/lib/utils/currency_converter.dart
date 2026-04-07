import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../enums/currency_enum.dart';

class CurrencyCubit extends Cubit<CurrencyType> {
  CurrencyCubit() : super(CurrencyType.idr);

  void toggleCurrency() {
    if (state == CurrencyType.idr) {
      emit(CurrencyType.usd);
    } else {
      emit(CurrencyType.idr);
    }
  }

  void setCurrency(CurrencyType type) => emit(type);

  String format(num amount) {
    if (state == CurrencyType.usd) {
      // Assuming naive conversion for demonstration: 1 USD = 15000 IDR
      // Ideally, the conversion rate should be fetched from an API or passed
      double usdAmount = amount / 15500.0;
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      ).format(usdAmount);
    } else {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
    }
  }
}
