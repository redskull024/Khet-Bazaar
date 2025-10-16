import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for handling all authentication and user-related Firestore operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === ROLE & PREFERENCE MANAGEMENT ===

  Future<void> saveTemporaryRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tempSelectedRole', role);
  }

  Future<String?> getTemporaryRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tempSelectedRole');
  }

  Future<Map<String, String?>?> getUserPreferences(String uid) async {
    try {
      final doc = await _firestore.collection('user_preferences').doc(uid).get();
      if (doc.exists) {
        return {
          'role': doc.data()?['role'],
          'languageCode': doc.data()?['languageCode'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return null;
    }
  }

  // === METADATA MANAGEMENT ===

  Future<void> saveUserMetadata(User user, String role, String name, {String? phoneNumber, String? languageCode}) async {
    final userRef = _firestore.collection('user_preferences').doc(user.uid);
    final data = {
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'role': role,
      'languageCode': languageCode,
      'createdAt': FieldValue.serverTimestamp(),
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
    await userRef.set(data, SetOptions(merge: true));
  }

  // === AUTHENTICATION METHODS ===

  Future<Map<String, String?>?> signUpWithEmail(Map<String, dynamic> userData) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );
      final user = userCredential.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final languageCode = prefs.getString('selectedLanguage');

        await saveUserMetadata(
          user,
          userData['role'],
          userData['name'],
          phoneNumber: userData['phoneNumber'],
          languageCode: languageCode,
        );
        return {'role': userData['role'], 'languageCode': languageCode};
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    }
  }

  Future<Map<String, String?>?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return await getUserPreferences(user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  Future<Map<String, String?>?> signInWithGoogle(String role) async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      final user = userCredential.user;

      if (user != null) {
        final userPrefs = await getUserPreferences(user.uid);
        if (userPrefs != null) {
          return userPrefs;
        } else {
          final prefs = await SharedPreferences.getInstance();
          final languageCode = prefs.getString('selectedLanguage');
          await saveUserMetadata(user, role, user.displayName ?? 'Google User', languageCode: languageCode);
          return {'role': role, 'languageCode': languageCode};
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In failed: ${e.message}');
      throw Exception('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred during Google Sign-In.');
    }
  }

  /// Initiates phone number verification. Does not handle UI.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  /// Signs in the user using the verification ID and SMS code from the UI.
  Future<Map<String, String?>?> signInWithSmsCode(String verificationId, String smsCode, String role, String? phoneNumber) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final userPrefs = await getUserPreferences(user.uid);
        if (userPrefs != null) {
          return userPrefs;
        } else {
          final prefs = await SharedPreferences.getInstance();
          final languageCode = prefs.getString('selectedLanguage');
          await saveUserMetadata(user, role, 'New User', phoneNumber: phoneNumber, languageCode: languageCode);
          return {'role': role, 'languageCode': languageCode};
        }
      }
      return null;
    } catch (e) {
      throw Exception("Failed to sign in with SMS code: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tempSelectedRole');
    await prefs.remove('selectedLanguage');
  }
}
