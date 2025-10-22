import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_connect/src/models/delivery_info_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getAddressesCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in. Cannot manage addresses.");
    }
    return _firestore.collection('users').doc(user.uid).collection('addresses');
  }

  /// Saves an address (adds if new, updates if ID exists).
  Future<void> saveAddress(DeliveryInfo address) async {
    if (address.id != null && address.id!.isNotEmpty) {
      await _getAddressesCollection().doc(address.id).set(address.toMap());
    } else {
      await _getAddressesCollection().add(address.toMap());
    }
  }

  /// Returns a stream of the current user's saved addresses.
  Stream<List<DeliveryInfo>> getAddressesStream() {
    return _getAddressesCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DeliveryInfo.fromFirestore(doc)).toList();
    });
  }
}
