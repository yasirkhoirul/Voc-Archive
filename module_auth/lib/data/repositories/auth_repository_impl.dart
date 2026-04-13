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
        String role = await _authDatasource.getUserRole(userCredential.user!.uid);
        return AppUserModel.fromFirebaseUser(userCredential.user!, role: role);
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
        String role = await _authDatasource.getUserRole(userCredential.user!.uid);
        return AppUserModel.fromFirebaseUser(userCredential.user!, role: role);
      } else {
        throw Exception('User is null');
      }
    })().guard();
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _authDatasource.authStateChanges().asyncMap((user) async {
      if (user != null) {
        String role = await _authDatasource.getUserRole(user.uid);
        return AppUserModel.fromFirebaseUser(user, role: role);
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
