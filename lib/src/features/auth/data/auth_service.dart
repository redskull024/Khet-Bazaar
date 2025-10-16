
import 'package:farm_connect/src/features/auth/data/firebase_auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuthWrapper _firebaseAuthWrapper;
  final FlutterSecureStorage _secureStorage;

  AuthService(this._firebaseAuthWrapper, this._secureStorage);

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuthWrapper.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuthWrapper.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuthWrapper.signOut();
  }
}
