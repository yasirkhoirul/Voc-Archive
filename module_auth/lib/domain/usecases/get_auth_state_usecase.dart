import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateUseCase {
  final AuthRepository _repository;

  GetAuthStateUseCase(this._repository);

  Stream<AppUser?> call() {
    return _repository.authStateChanges();
  }
}
