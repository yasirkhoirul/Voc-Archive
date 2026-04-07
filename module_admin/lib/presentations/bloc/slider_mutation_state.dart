part of 'slider_mutation_bloc.dart';

abstract class SliderMutationState extends Equatable {
  const SliderMutationState();

  @override
  List<Object?> get props => [];
}

class SliderMutationInitial extends SliderMutationState {}

class SliderMutationLoading extends SliderMutationState {}

class SliderMutationSuccess extends SliderMutationState {}

class SliderMutationError extends SliderMutationState {
  final String message;

  const SliderMutationError(this.message);

  @override
  List<Object?> get props => [message];
}
