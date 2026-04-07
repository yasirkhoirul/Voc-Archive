import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_home_repository.dart';

class DeleteSliderUseCase {
  final AdminHomeRepository _repository;

  DeleteSliderUseCase(this._repository);

  Future<Either<Failure, void>> call(String uid) {
    return _repository.deleteSlider(uid);
  }
}
