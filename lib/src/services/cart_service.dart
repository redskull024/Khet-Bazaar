import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';

/// Manages shopping cart operations in Firestore.
///
/// This service handles adding, updating, and removing items from the user's
/// cart, including logic to combine quantities for identical items.
class CartService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// A reference to the 'cart' subcollection for the currently authenticated user.
  CollectionReference _getCartCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }
    return _firestore.collection('users').doc(user.uid).collection('cart');
  }

  /// Adds a new item to the cart or updates the quantity if it already exists.
  ///
  /// Checks if an item with the same `listingId` is already in the cart.
  /// If it exists, it adds the new quantity to the existing item's quantity.
  /// If it's a new item, it creates a new document in the cart.
  Future<void> addToCart(CartItem newItem) async {
    final cartCollection = _getCartCollection();
    final querySnapshot = await cartCollection
        .where('listingId', isEqualTo: newItem.listingId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Item already exists, update the quantity
      final doc = querySnapshot.docs.first;
      final existingQuantity = (doc.data() as Map<String, dynamic>)['totalQuantityInKg'] ?? 0.0;
      final newQuantity = existingQuantity + newItem.totalQuantityInKg;
      await doc.reference.update({'totalQuantityInKg': newQuantity});
    } else {
      // Item is new, add it to the cart
      await cartCollection.add(newItem.toMap());
    }
  }

  /// Removes an item completely from the cart.
  Future<void> removeItem(String cartItemId) async {
    await _getCartCollection().doc(cartItemId).delete();
  }

  /// Updates the quantity of a specific item in the cart.
  ///
  /// If the new quantity is zero or less, the item is removed from the cart.
  Future<void> updateQuantity(String cartItemId, double newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(cartItemId);
    } else {
      await _getCartCollection().doc(cartItemId).update({'totalQuantityInKg': newQuantity});
    }
  }

  /// Returns a stream of the user's cart items.
  ///
  /// Listens to real-time updates in the user's cart and provides a list
  /// of [CartItem] objects.
  Stream<List<CartItem>> getCartStream() {
    return _getCartCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Deletes all items from the user's cart.
  Future<void> clearCart() async {
    final cartCollection = _getCartCollection();
    final snapshot = await cartCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}