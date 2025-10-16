import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:farm_connect/src/features/auth/domain/entities/user.dart';
import 'package:farm_connect/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null ? null : User(uid: firebaseUser.uid, email: firebaseUser.email);
    });
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user;
    return firebaseUser == null ? null : User(uid: firebaseUser.uid, email: firebaseUser.email);
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user;
    return firebaseUser == null ? null : User(uid: firebaseUser.uid, email: firebaseUser.email);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
