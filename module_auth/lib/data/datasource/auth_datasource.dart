import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:module_core/module_core.dart';

abstract class AuthDatasource {
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> registerWithEmailAndPassword(String email, String password);
  Stream<User?> authStateChanges();
  Future<void> signOut();
  Future<String> getUserRole(String uid);
}

class AuthDatasourceImpl implements AuthDatasource {
  AuthDatasourceImpl(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    final response = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).guardDatasource();
    return response;
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

  @override
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String? ?? 'user';
      }
      return 'user';
    } catch (e) {
      return 'user';
    }
  }
}