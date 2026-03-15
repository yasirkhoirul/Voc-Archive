import 'package:firebase_auth/firebase_auth.dart';
import 'package:module_core/module_core.dart';

abstract class AuthDatasource {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> registerWithEmailAndPassword(String email, String password);
  Stream<User?> authStateChanges();
  Future<void> signOut();
}

class AuthDatasourceImpl implements AuthDatasource {
  AuthDatasourceImpl(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final response = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).guard();
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> registerWithEmailAndPassword(String email, String password) async{
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).guard();
  }
  
  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}