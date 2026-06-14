enum PaymentMethod { paypal, other }

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.other:
        return 'Xendit (IDR)';
    }
  }
}
