import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitFeedback(String feedbackText) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    if (feedbackText.trim().isEmpty) {
      throw Exception("Feedback cannot be empty");
    }

    await _firestore.collection('feedback').add({
      'userId': user.uid,
      'userEmail': user.email, // Storing email for context
      'feedbackText': feedbackText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
