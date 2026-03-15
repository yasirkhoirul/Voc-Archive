import 'package:dartz/dartz.dart';
import 'package:module_core/utils/failure.dart';
import 'package:module_core/utils/runcatching.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_datasource.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _authDatasource;

  AuthRepositoryImpl(this._authDatasource);

  @override
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(String email, String password) async {
    return await (() async {
      final userCredential = await _authDatasource.signInWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        return AppUserModel.fromFirebaseUser(userCredential.user!);
      } else {
        throw Exception('User is null');
      }
    })().guard();
  }

  @override
  Future<Either<Failure, AppUser>> registerWithEmailAndPassword(String email, String password) async {
    return await (() async {
      final userCredential = await _authDatasource.registerWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        return AppUserModel.fromFirebaseUser(userCredential.user!);
      } else {
        throw Exception('User is null');
      }
    })().guard();
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _authDatasource.authStateChanges().map((user) {
      if (user != null) {
        return AppUserModel.fromFirebaseUser(user);
      }
      return null;
    });
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return await (() async {
      await _authDatasource.signOut();
    })().guard();
  }
}
