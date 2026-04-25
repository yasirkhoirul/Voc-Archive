import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_entities/order_history.dart';
import 'package:module_core/shared_domain/shared_usecases/get_history_by_user_id_usecase.dart';

part 'history_user_state.dart';

class HistoryUserCubit extends Cubit<HistoryUserState> {
  final GetHistoryByUserIdUseCase _getHistoryByUserId;
  final FirebaseFunctions _functions;

  HistoryUserCubit(this._getHistoryByUserId, this._functions)
      : super(HistoryUserInitial());

  /// Syncs user's pending Midtrans orders first, then fetches history.
  Future<void> fetchHistory(String userId) async {
    emit(HistoryUserSyncing());

    // Step 1: Sync user's pending Midtrans orders
    try {
      await _functions
          .httpsCallable('syncUserPendingMidtransOrders')
          .call();
    } catch (e) {
      // If sync fails, continue to fetch history anyway
      // ignore: avoid_print
      print('[HistoryUserCubit] Sync failed: $e');
    }

    // Step 2: Fetch user's history
    emit(HistoryUserLoading());
    final result = await _getHistoryByUserId.call(userId);
    result.fold(
      (failure) => emit(HistoryUserError(failure.message)),
      (histories) => emit(HistoryUserLoaded(histories)),
    );
  }
}
