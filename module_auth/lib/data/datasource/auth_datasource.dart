import 'package:firebase_auth/firebase_auth.dart';
import 'package:module_core/module_core.dart';

abstract class AuthDatasource {
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> registerWithEmailAndPassword(String email, String password);
  Stream<User?> authStateChanges();
  Future<void> signOut();
}

class AuthDatasourceImpl implements AuthDatasource {
  AuthDatasourceImpl(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).guardDatasource();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut().guardDatasource();
  }

  @override
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async{
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).guardDatasource();
  }
  
  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}