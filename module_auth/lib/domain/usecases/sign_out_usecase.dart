import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.signOut();
  }
}
