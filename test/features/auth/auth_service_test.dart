
import 'package:farm_connect/src/features/auth/data/auth_service.dart';
import 'package:farm_connect/src/features/auth/data/firebase_auth_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockFirebaseAuthWrapper extends Mock implements FirebaseAuthWrapper {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuthWrapper mockFirebaseAuthWrapper;
    late MockFlutterSecureStorage mockFlutterSecureStorage;

    setUp(() {
      mockFirebaseAuthWrapper = MockFirebaseAuthWrapper();
      mockFlutterSecureStorage = MockFlutterSecureStorage();
      authService = AuthService(mockFirebaseAuthWrapper, mockFlutterSecureStorage);
    });

    test('signInWithEmailAndPassword returns a User on success', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuthWrapper.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      )).thenAnswer((_) async => Future.value(MockUserCredential()));

      final user = await authService.signInWithEmailAndPassword(
        'test@test.com',
        'password',
      );

      expect(user, isA<User>());
    });

    test('signUpWithEmailAndPassword returns a User on success', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuthWrapper.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      )).thenAnswer((_) async => Future.value(MockUserCredential()));

      final user = await authService.signUpWithEmailAndPassword(
        'test@test.com',
        'password',
      );

      expect(user, isA<User>());
    });

    test('signOut calls signOut on FirebaseAuthWrapper', () {
      when(mockFirebaseAuthWrapper.signOut()).thenAnswer((_) => Future.value());
      authService.signOut();
      verify(mockFirebaseAuthWrapper.signOut()).called(1);
    });
  });
}
