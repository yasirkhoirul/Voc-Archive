part of 'history_user_cubit.dart';

sealed class HistoryUserState extends Equatable {
  const HistoryUserState();

  @override
  List<Object> get props => [];
}

final class HistoryUserInitial extends HistoryUserState {}

final class HistoryUserSyncing extends HistoryUserState {}

final class HistoryUserLoading extends HistoryUserState {}

final class HistoryUserLoaded extends HistoryUserState {
  final List<OrderHistoryEntity> histories;

  const HistoryUserLoaded(this.histories);

  @override
  List<Object> get props => [histories];
}

final class HistoryUserError extends HistoryUserState {
  final String message;

  const HistoryUserError(this.message);

  @override
  List<Object> get props => [message];
}
