import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/update_display_input.dart';
import '../repositories/admin_home_repository.dart';

class UpdateDisplayUseCase {
  final AdminHomeRepository _repository;

  UpdateDisplayUseCase(this._repository);

  Future<Either<Failure, void>> call(UpdateDisplayInput input) {
    return _repository.updateDisplay(input);
  }
}
