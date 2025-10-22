
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String uuid;
  final String productName;
  final String farmerName;
  final String buyerName;
  final Timestamp listedDate;
  final Timestamp purchasedDate;
  final int quantity;
  final double perProductPrice;
  final double totalPrice;

  PurchaseModel({
    required this.uuid,
    required this.productName,
    required this.farmerName,
    required this.buyerName,
    required this.listedDate,
    required this.purchasedDate,
    required this.quantity,
    required this.perProductPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'productName': productName,
      'farmerName': farmerName,
      'buyerName': buyerName,
      'listedDate': listedDate,
      'purchasedDate': purchasedDate,
      'quantity': quantity,
      'perProductPrice': perProductPrice,
      'totalPrice': totalPrice,
    };
  }
}
