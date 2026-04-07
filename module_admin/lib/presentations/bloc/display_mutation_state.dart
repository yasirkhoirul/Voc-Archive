part of 'display_mutation_bloc.dart';

abstract class DisplayMutationState extends Equatable {
  const DisplayMutationState();

  @override
  List<Object?> get props => [];
}

class DisplayMutationInitial extends DisplayMutationState {}

class DisplayMutationLoading extends DisplayMutationState {}

class DisplayMutationSuccess extends DisplayMutationState {}

class DisplayMutationError extends DisplayMutationState {
  final String message;

  const DisplayMutationError(this.message);

  @override
  List<Object?> get props => [message];
}
