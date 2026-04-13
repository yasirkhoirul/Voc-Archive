import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:module_user/domain/entities/slider.dart';
import 'package:module_user/domain/usecases/get_sliders_usecase.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetSlidersUsecase _getAllSliderUseCase;

  HomeCubit(this._getAllSliderUseCase) : super(HomeInitial());

  Future<void> fetchSliders() async {
    emit(HomeLoading());
    final result = await _getAllSliderUseCase();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (sliders) => emit(HomeLoaded(sliders)),
    );
  }
}
