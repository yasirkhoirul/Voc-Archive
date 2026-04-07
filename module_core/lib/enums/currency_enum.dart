enum CurrencyType {
  idr,
  usd
}

extension CurrencyTypeExt on CurrencyType {
  String get name {
    switch (this) {
      case CurrencyType.idr:
        return 'IDR';
      case CurrencyType.usd:
        return 'USD';
    }
  }
}
