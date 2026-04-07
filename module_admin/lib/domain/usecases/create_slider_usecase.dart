import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/create_slider_input.dart';
import '../repositories/admin_home_repository.dart';

class CreateSliderUseCase {
  final AdminHomeRepository _repository;

  CreateSliderUseCase(this._repository);

  Future<Either<Failure, void>> call(CreateSliderInput input) {
    return _repository.createSlider(input);
  }
}
