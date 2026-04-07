import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/create_display_input.dart';
import '../repositories/admin_home_repository.dart';

class CreateDisplayUseCase {
  final AdminHomeRepository _repository;

  CreateDisplayUseCase(this._repository);

  Future<Either<Failure, void>> call(CreateDisplayInput input) {
    return _repository.createDisplay(input);
  }
}
