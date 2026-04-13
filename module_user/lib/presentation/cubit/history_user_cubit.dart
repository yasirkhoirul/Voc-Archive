import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_entities/order_history.dart';
import 'package:module_core/shared_domain/shared_usecases/get_history_by_user_id_usecase.dart';

part 'history_user_state.dart';

class HistoryUserCubit extends Cubit<HistoryUserState> {
  final GetHistoryByUserIdUseCase _getHistoryByUserId;

  HistoryUserCubit(this._getHistoryByUserId) : super(HistoryUserInitial());

  Future<void> fetchHistory(String userId) async {
    emit(HistoryUserLoading());
    final result = await _getHistoryByUserId.call(userId);
    result.fold(
      (failure) => emit(HistoryUserError(failure.message)),
      (histories) => emit(HistoryUserLoaded(histories)),
    );
  }
}
