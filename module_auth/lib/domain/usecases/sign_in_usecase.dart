import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Either<Failure, AppUser>> call(String email, String password) {
    return _repository.signInWithEmailAndPassword(email, password);
  }
}
