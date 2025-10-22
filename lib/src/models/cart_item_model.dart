import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String listingId;
  final String uuid;
  final String farmerUID;
  final String productName;
  final double quantityInKg;
  final double pricePerKg;
  final String imageUrl;
  final String buyerUID;
  final Timestamp? timestamp;

  CartItem({
    required this.listingId,
    required this.uuid,
    required this.farmerUID,
    required this.productName,
    required this.quantityInKg,
    required this.pricePerKg,
    required this.imageUrl,
    required this.buyerUID,
    this.timestamp,
  });

  // Getter for calculated total price
  double get totalPrice => pricePerKg * quantityInKg;

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      listingId: data['listingId'] ?? '',
      uuid: data['uuid'] ?? '',
      farmerUID: data['farmerUID'] ?? '',
      productName: data['productName'] ?? '',
      quantityInKg: (data['quantityInKg'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (data['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      buyerUID: data['buyerUID'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'uuid': uuid,
      'farmerUID': farmerUID,
      'productName': productName,
      'quantityInKg': quantityInKg,
      'pricePerKg': pricePerKg,
      'imageUrl': imageUrl,
      'buyerUID': buyerUID,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }

  // copyWith method to easily update instances
  CartItem copyWith({
    double? quantityInKg,
  }) {
    return CartItem(
      listingId: listingId,
      uuid: uuid,
      farmerUID: farmerUID,
      productName: productName,
      quantityInKg: quantityInKg ?? this.quantityInKg,
      pricePerKg: pricePerKg,
      imageUrl: imageUrl,
      buyerUID: buyerUID,
      timestamp: timestamp,
    );
  }
}

