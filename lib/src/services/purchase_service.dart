
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/purchase_model.dart';

class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> savePurchase(PurchaseModel purchase) async {
    try {
      await _firestore.collection('purchase_success').add(purchase.toMap());
    } catch (e) {
      // Handle error
      print('Error saving purchase: $e');
    }
  }
}
