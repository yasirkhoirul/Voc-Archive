part of 'history_cubit.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistorySyncing extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<OrderHistoryEntity> historyList;

  const HistoryLoaded({required this.historyList});

  @override
  List<Object?> get props => [historyList];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

class HistoryActionLoading extends HistoryState {
  final String orderId;

  const HistoryActionLoading({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class HistoryActionError extends HistoryState {
  final String orderId;
  final String message;

  const HistoryActionError({required this.orderId, required this.message});

  @override
  List<Object?> get props => [orderId, message];
}
