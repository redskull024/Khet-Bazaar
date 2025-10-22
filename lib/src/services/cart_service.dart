import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getCartItemsCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(user.uid).collection('cart');
  }

  Future<void> addToCart(CartItem item) async {
    await _getCartItemsCollection().doc(item.listingId).set(item.toMap());
  }

  Stream<List<CartItem>> getCartStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _getCartItemsCollection()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CartItem.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> removeFromCart(String listingId) async {
    await _getCartItemsCollection().doc(listingId).delete();
  }

  Future<void> clearCart() async {
    final cartItems = await _getCartItemsCollection().get();
    for (final doc in cartItems.docs) {
      await doc.reference.delete();
    }
  }
}
