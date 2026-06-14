import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_usecases/get_shipping_rates_usecase.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final GetShippingRatesUsecase getShippingRatesUsecase;
  final FirebaseFunctions _functions;

  CheckoutBloc({
    required this.getShippingRatesUsecase,
    required FirebaseFunctions functions,
  }) : _functions = functions,
       super(const CheckoutState()) {
    on<NextStepEvent>((event, emit) {
      if (state.step < 2) {
        emit(state.copyWith(step: state.step + 1));
      }
    });

    on<PreviousStepEvent>((event, emit) {
      if (state.step > 0) {
        emit(state.copyWith(step: state.step - 1));
      }
    });

    on<LoadShippingRatesEvent>((event, emit) async {
      emit(state.copyWith(isLoadingRates: true, ratesError: null));
      final result = await getShippingRatesUsecase();
      result.fold(
        (failure) => emit(
          state.copyWith(isLoadingRates: false, ratesError: failure.message),
        ),
        (rates) =>
            emit(state.copyWith(isLoadingRates: false, shippingRates: rates)),
      );
    });

    on<UpdateShippingRateEvent>((event, emit) {
      emit(state.copyWith(selectedShippingRate: event.selectedRate));
    });

    on<ProcessXenditPaymentEvent>(_onProcessXenditPayment);
    on<ProcessPaypalPaymentEvent>(_onProcessPaypalPayment);
    on<CheckPaymentStatusEvent>(_onCheckPaymentStatus);
    on<ResetCheckoutEvent>((event, emit) {
      emit(CheckoutState(shippingRates: state.shippingRates));
    });
  }

  Future<void> _onProcessXenditPayment(
    ProcessXenditPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(isProcessingPayment: true, paymentError: null));
    try {
      final callable = _functions.httpsCallable('createXenditInvoice');
      final result = await callable.call({
        'items': event.items,
        'shipping_area': event.shippingArea,
        'customer': {
          'name': event.name,
          'email': event.email,
          'phone': event.phone,
          'city': event.city,
          'postal_code': event.postalCode,
          'address': event.address,
        },
      });
      final data = result.data['data'] as Map<String, dynamic>;
      emit(state.copyWith(
        isProcessingPayment: false,
        redirectUrl: data['invoice_url'] as String?,
        orderId: data['order_id'] as String?,
        totalIdr: (data['total_idr'] as num?)?.toDouble(),
        totalUsd: (data['total_usd'] as num?)?.toDouble(),
        paymentStatus: 'pending',
      ));
    } catch (e) {
      emit(state.copyWith(isProcessingPayment: false, paymentError: e.toString()));
    }
  }

  Future<void> _onProcessPaypalPayment(
    ProcessPaypalPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(isProcessingPayment: true, paymentError: null));
    try {
      final fileName = 'proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'payment_proofs/$fileName',
      );
      await storageRef.putData(
        event.proofImageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final proofUrl = await storageRef.getDownloadURL();

      final callable = _functions.httpsCallable(
        'createPaypalManualTransaction',
      );
      final result = await callable.call({
        'items': event.items,
        'shipping_area': event.shippingArea,
        'proof_url': proofUrl,
        'customer': {
          'name': event.name,
          'email': event.email,
          'phone': event.phone,
          'city': event.city,
          'postal_code': event.postalCode,
          'address': event.address,
        },
      });

      final data = result.data['data'] as Map<String, dynamic>;
      emit(
        state.copyWith(
          isProcessingPayment: false,
          orderId: data['order_id'] as String?,
          totalIdr: (data['total_idr'] as num?)?.toDouble(),
          totalUsd: (data['total_usd'] as num?)?.toDouble(),
          paymentStatus: 'pending',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isProcessingPayment: false, paymentError: e.toString()),
      );
    }
  }

  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatusEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      final callable = _functions.httpsCallable('checkXenditStatus');
      final result = await callable.call({'order_id': event.orderId});
      final data = result.data['data'] as Map<String, dynamic>;
      emit(state.copyWith(paymentStatus: data['status'] as String?));
    } catch (e) {
      emit(state.copyWith(paymentError: e.toString()));
    }
  }
}
