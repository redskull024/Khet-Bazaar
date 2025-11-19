import 'package:cloud_firestore/cloud_firestore.dart';

class SalesNotificationModel {
  final String orderId;
  final String productId;
  final String productName;
  final double quantitySold;
  final String unit;
  final String buyerName;
  final String buyerLocation;
  final Timestamp saleTimestamp;
  final String farmerUID;

  SalesNotificationModel({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.unit,
    required this.buyerName,
    required this.buyerLocation,
    required this.saleTimestamp,
    required this.farmerUID,
  });

  // Factory constructor to create a SalesNotificationModel from a Firestore document
  factory SalesNotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SalesNotificationModel(
      orderId: data['orderId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantitySold: (data['quantitySold'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
      buyerName: data['buyerName'] ?? '',
      buyerLocation: data['buyerLocation'] ?? '',
      saleTimestamp: data['saleTimestamp'] ?? Timestamp.now(),
      farmerUID: data['farmerUID'] ?? '',
    );
  }

  // Method to convert a SalesNotificationModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantitySold': quantitySold,
      'unit': unit,
      'buyerName': buyerName,
      'buyerLocation': buyerLocation,
      'saleTimestamp': saleTimestamp,
      'farmerUID': farmerUID,
    };
  }
}
