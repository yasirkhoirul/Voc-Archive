import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/create_display_input.dart';
import '../../domain/entities/update_display_input.dart';
import '../../domain/usecases/create_display_usecase.dart';
import '../../domain/usecases/update_display_usecase.dart';
import '../../domain/usecases/delete_display_usecase.dart';

part 'display_mutation_event.dart';
part 'display_mutation_state.dart';

class DisplayMutationBloc
    extends Bloc<DisplayMutationEvent, DisplayMutationState> {
  final CreateDisplayUseCase _createDisplayUseCase;
  final UpdateDisplayUseCase _updateDisplayUseCase;
  final DeleteDisplayUseCase _deleteDisplayUseCase;

  DisplayMutationBloc(
    this._createDisplayUseCase,
    this._updateDisplayUseCase,
    this._deleteDisplayUseCase,
  ) : super(DisplayMutationInitial()) {
    on<CreateDisplaySubmitted>(_onCreateDisplay);
    on<UpdateDisplaySubmitted>(_onUpdateDisplay);
    on<DeleteDisplaySubmitted>(_onDeleteDisplay);
  }

  Future<void> _onCreateDisplay(
    CreateDisplaySubmitted event,
    Emitter<DisplayMutationState> emit,
  ) async {
    emit(DisplayMutationLoading());
    final result = await _createDisplayUseCase(event.input);
    result.fold(
      (failure) => emit(DisplayMutationError(failure.message)),
      (_) => emit(DisplayMutationSuccess()),
    );
  }

  Future<void> _onUpdateDisplay(
    UpdateDisplaySubmitted event,
    Emitter<DisplayMutationState> emit,
  ) async {
    emit(DisplayMutationLoading());
    final result = await _updateDisplayUseCase(event.input);
    result.fold(
      (failure) => emit(DisplayMutationError(failure.message)),
      (_) => emit(DisplayMutationSuccess()),
    );
  }

  Future<void> _onDeleteDisplay(
    DeleteDisplaySubmitted event,
    Emitter<DisplayMutationState> emit,
  ) async {
    emit(DisplayMutationLoading());
    final result = await _deleteDisplayUseCase(event.uid);
    result.fold(
      (failure) => emit(DisplayMutationError(failure.message)),
      (_) => emit(DisplayMutationSuccess()),
    );
  }
}
