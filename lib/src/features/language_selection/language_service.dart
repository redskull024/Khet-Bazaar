import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service class to handle language selection persistence.
class LanguageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Saves the user's language selection to both local storage and Firestore.
  ///
  /// - [localeCode]: The language code to save (e.g., 'en', 'hi').
  Future<void> saveLanguageSelection(String localeCode) async {
    // This is a placeholder for a signed-in user. In a real app,
    // you would get the user after they have authenticated.
    // For the purpose of this feature, we assume a user is signed in
    // or we proceed without Firebase persistence if no user is found.
    final user = _auth.currentUser;

    // 1. Local Persistence: Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageCode', localeCode);

    // 2. Firebase Persistence: Save to Firestore if a user is logged in.
    if (user != null) {
      await _firestore.collection('user_preferences').doc(user.uid).set({
        'languageCode': localeCode,
      }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
    }
  }
}