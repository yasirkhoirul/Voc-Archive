import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_usecases/get_all_history_usecase.dart';
import 'package:module_core/shared_domain/shared_entities/order_history.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final GetAllHistoryUseCase getAllHistoryUseCase;
  final FirebaseFunctions functions;

  HistoryCubit({
    required this.getAllHistoryUseCase,
    required this.functions,
  }) : super(HistoryInitial());

  /// Syncs all pending Midtrans orders first, then fetches all history.
  Future<void> fetchAllHistory() async {
    emit(HistorySyncing());

    // Step 1: Sync pending Midtrans orders (admin syncs ALL orders)
    try {
      await functions.httpsCallable('syncPendingMidtransOrders').call();
    } catch (e) {
      // ignore: avoid_print
      print('[HistoryCubit] Sync failed: $e');
    }

    // Step 2: Fetch all history
    emit(HistoryLoading());
    final result = await getAllHistoryUseCase();

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (historyList) => emit(HistoryLoaded(historyList: historyList)),
    );
  }

  /// Confirm a pending PayPal order
  Future<void> confirmPaypalOrder(String orderId) async {
    emit(HistoryActionLoading(orderId: orderId));
    try {
      await functions.httpsCallable('confirmPaypalOrder').call({
        'order_id': orderId,
      });
      // Refresh history after action
      await fetchAllHistory();
    } catch (e) {
      emit(HistoryActionError(
        orderId: orderId,
        message: e.toString(),
      ));
    }
  }

  /// Reject a pending PayPal order
  Future<void> rejectPaypalOrder(String orderId) async {
    emit(HistoryActionLoading(orderId: orderId));
    try {
      await functions.httpsCallable('rejectPaypalOrder').call({
        'order_id': orderId,
      });
      // Refresh history after action
      await fetchAllHistory();
    } catch (e) {
      emit(HistoryActionError(
        orderId: orderId,
        message: e.toString(),
      ));
    }
  }
}
