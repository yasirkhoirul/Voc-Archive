import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, AppUser>> registerWithEmailAndPassword(String email, String password);
  Stream<AppUser?> authStateChanges();
  Future<Either<Failure, void>> signOut();
}
