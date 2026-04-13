part of 'checkout_bloc.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class NextStepEvent extends CheckoutEvent {}

class PreviousStepEvent extends CheckoutEvent {}

class LoadShippingRatesEvent extends CheckoutEvent {}

class UpdateShippingRateEvent extends CheckoutEvent {
  final Map<String, dynamic>? selectedRate;

  const UpdateShippingRateEvent(this.selectedRate);

  @override
  List<Object?> get props => [selectedRate];
}

class ProcessMidtransPaymentEvent extends CheckoutEvent {
  final List<Map<String, dynamic>> items; // [{product_id, quantity, size}]
  final String shippingArea;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String postalCode;
  final String address;

  const ProcessMidtransPaymentEvent({
    required this.items,
    required this.shippingArea,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.postalCode,
    required this.address,
  });

  @override
  List<Object?> get props =>
      [items, shippingArea, name, email, phone, city, postalCode, address];
}

class ProcessPaypalPaymentEvent extends CheckoutEvent {
  final List<Map<String, dynamic>> items;
  final String shippingArea;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String postalCode;
  final String address;
  final Uint8List proofImageBytes;

  const ProcessPaypalPaymentEvent({
    required this.items,
    required this.shippingArea,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.postalCode,
    required this.address,
    required this.proofImageBytes,
  });

  @override
  List<Object?> get props =>
      [items, shippingArea, name, email, phone, city, postalCode, address, proofImageBytes];
}

class CheckPaymentStatusEvent extends CheckoutEvent {
  final String orderId;

  const CheckPaymentStatusEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class ResetCheckoutEvent extends CheckoutEvent {}
