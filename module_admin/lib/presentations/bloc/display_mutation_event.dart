part of 'display_mutation_bloc.dart';

abstract class DisplayMutationEvent extends Equatable {
  const DisplayMutationEvent();

  @override
  List<Object?> get props => [];
}

class CreateDisplaySubmitted extends DisplayMutationEvent {
  final CreateDisplayInput input;

  const CreateDisplaySubmitted(this.input);

  @override
  List<Object?> get props => [input];
}

class UpdateDisplaySubmitted extends DisplayMutationEvent {
  final UpdateDisplayInput input;

  const UpdateDisplaySubmitted(this.input);

  @override
  List<Object?> get props => [input];
}

class DeleteDisplaySubmitted extends DisplayMutationEvent {
  final String uid;

  const DeleteDisplaySubmitted(this.uid);

  @override
  List<Object?> get props => [uid];
}
