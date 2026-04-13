part of 'checkout_bloc.dart';

class CheckoutState extends Equatable {
  final int step;
  final List<Map<String, dynamic>> shippingRates;
  final bool isLoadingRates;
  final String? ratesError;
  final Map<String, dynamic>? selectedShippingRate;

  // Payment
  final bool isProcessingPayment;
  final String? paymentError;
  final String? snapToken;
  final String? redirectUrl;
  final String? orderId;
  final String? paymentStatus; // pending, settlement, expire, cancel, deny
  final double? totalIdr;
  final double? totalUsd;

  const CheckoutState({
    this.step = 0,
    this.shippingRates = const [],
    this.isLoadingRates = false,
    this.ratesError,
    this.selectedShippingRate,
    this.isProcessingPayment = false,
    this.paymentError,
    this.snapToken,
    this.redirectUrl,
    this.orderId,
    this.paymentStatus,
    this.totalIdr,
    this.totalUsd,
  });

  CheckoutState copyWith({
    int? step,
    List<Map<String, dynamic>>? shippingRates,
    bool? isLoadingRates,
    String? ratesError,
    Map<String, dynamic>? selectedShippingRate,
    bool? isProcessingPayment,
    String? paymentError,
    String? snapToken,
    String? redirectUrl,
    String? orderId,
    String? paymentStatus,
    double? totalIdr,
    double? totalUsd,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      shippingRates: shippingRates ?? this.shippingRates,
      isLoadingRates: isLoadingRates ?? this.isLoadingRates,
      ratesError: ratesError ?? this.ratesError,
      selectedShippingRate: selectedShippingRate ?? this.selectedShippingRate,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      paymentError: paymentError,
      snapToken: snapToken ?? this.snapToken,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      orderId: orderId ?? this.orderId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalIdr: totalIdr ?? this.totalIdr,
      totalUsd: totalUsd ?? this.totalUsd,
    );
  }

  @override
  List<Object?> get props => [
        step,
        shippingRates,
        isLoadingRates,
        ratesError,
        selectedShippingRate,
        isProcessingPayment,
        paymentError,
        snapToken,
        redirectUrl,
        orderId,
        paymentStatus,
        totalIdr,
        totalUsd,
      ];
}
