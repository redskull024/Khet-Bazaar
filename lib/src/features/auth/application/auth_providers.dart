import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_connect/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:farm_connect/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:farm_connect/src/features/auth/application/auth_service.dart';
import 'package:farm_connect/src/features/auth/domain/entities/user.dart';


final firebaseAuthProvider = Provider<firebase.FirebaseAuth>((ref) {
  return firebase.FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authRepositoryProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
