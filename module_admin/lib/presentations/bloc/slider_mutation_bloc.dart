import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/create_slider_input.dart';
import '../../domain/usecases/create_slider_usecase.dart';
import '../../domain/usecases/delete_slider_usecase.dart';

part 'slider_mutation_event.dart';
part 'slider_mutation_state.dart';

class SliderMutationBloc
    extends Bloc<SliderMutationEvent, SliderMutationState> {
  final CreateSliderUseCase _createSliderUseCase;
  final DeleteSliderUseCase _deleteSliderUseCase;

  SliderMutationBloc(
    this._createSliderUseCase,
    this._deleteSliderUseCase,
  ) : super(SliderMutationInitial()) {
    on<CreateSliderSubmitted>(_onCreateSlider);
    on<DeleteSliderSubmitted>(_onDeleteSlider);
  }

  Future<void> _onCreateSlider(
    CreateSliderSubmitted event,
    Emitter<SliderMutationState> emit,
  ) async {
    emit(SliderMutationLoading());
    final result = await _createSliderUseCase(event.input);
    result.fold(
      (failure) => emit(SliderMutationError(failure.message)),
      (_) => emit(SliderMutationSuccess()),
    );
  }

  Future<void> _onDeleteSlider(
    DeleteSliderSubmitted event,
    Emitter<SliderMutationState> emit,
  ) async {
    emit(SliderMutationLoading());
    final result = await _deleteSliderUseCase(event.uid);
    result.fold(
      (failure) => emit(SliderMutationError(failure.message)),
      (_) => emit(SliderMutationSuccess()),
    );
  }
}
