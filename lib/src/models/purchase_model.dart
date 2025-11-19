
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String uuid;
  final String productName;
  final String farmerName;
  final String farmerUID; // Added for filtering
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
    required this.farmerUID,
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
      'farmerUID': farmerUID,
      'buyerName': buyerName,
      'listedDate': listedDate,
      'purchasedDate': purchasedDate,
      'quantity': quantity,
      'perProductPrice': perProductPrice,
      'totalPrice': totalPrice,
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      uuid: map['uuid'] ?? '',
      productName: map['productName'] ?? '',
      farmerName: map['farmerName'] ?? '',
      farmerUID: map['farmerUID'] ?? '',
      buyerName: map['buyerName'] ?? '',
      listedDate: map['listedDate'] ?? Timestamp.now(),
      purchasedDate: map['purchasedDate'] ?? Timestamp.now(),
      quantity: map['quantity'] ?? 0,
      perProductPrice: (map['perProductPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}
