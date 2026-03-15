import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, AppUser>> call(String email, String password) {
    return _repository.registerWithEmailAndPassword(email, password);
  }
}
