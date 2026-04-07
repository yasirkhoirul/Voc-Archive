part of 'slider_mutation_bloc.dart';

abstract class SliderMutationEvent extends Equatable {
  const SliderMutationEvent();

  @override
  List<Object?> get props => [];
}

class CreateSliderSubmitted extends SliderMutationEvent {
  final CreateSliderInput input;

  const CreateSliderSubmitted(this.input);

  @override
  List<Object?> get props => [input];
}

class DeleteSliderSubmitted extends SliderMutationEvent {
  final String uid;

  const DeleteSliderSubmitted(this.uid);

  @override
  List<Object?> get props => [uid];
}
