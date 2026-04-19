import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_user/domain/entities/display_section.dart';
import 'package:module_user/domain/usecases/get_display_sections_usecase.dart';

part 'display_state.dart';

class DisplayCubit extends Cubit<DisplayState> {
  final GetDisplaySectionsUsecase _getDisplaySectionsUsecase;
  DisplayCubit(this._getDisplaySectionsUsecase) : super(DisplayInitial());

  Future<void> fetchDisplaySection() async {
    emit(DisplayLoading());
    final result = await _getDisplaySectionsUsecase();
    result.fold((failure) => emit(DisplayError(failure.message)), (
      displaySections,
    ) {
      if (displaySections.isNotEmpty) {
        emit(DisplaySuccess(displaySections));
      } else {
        emit(const DisplayError('No display sections found'));
      }
    });
  }
}
