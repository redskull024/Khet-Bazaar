
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthWrapper {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthWrapper(this._firebaseAuth);

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
