import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/admin_home_repository.dart';

class DeleteDisplayUseCase {
  final AdminHomeRepository _repository;

  DeleteDisplayUseCase(this._repository);

  Future<Either<Failure, void>> call(String uid) {
    return _repository.deleteDisplay(uid);
  }
}
