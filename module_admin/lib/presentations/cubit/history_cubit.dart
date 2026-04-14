import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_core/shared_domain/shared_usecases/get_all_history_usecase.dart';
import 'package:module_core/shared_domain/shared_entities/order_history.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final GetAllHistoryUseCase getAllHistoryUseCase;

  HistoryCubit({required this.getAllHistoryUseCase}) : super(HistoryInitial());

  Future<void> fetchAllHistory() async {
    emit(HistoryLoading());
    final result = await getAllHistoryUseCase();

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (historyList) => emit(HistoryLoaded(historyList: historyList)),
    );
  }
}
