import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/delivery_info_model.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final List<OrderItem> items;
  final double totalAmount;
  final DeliveryInfo deliveryInfo;
  final Timestamp createdAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    required this.deliveryInfo,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryInfo: DeliveryInfo.fromMap(data['deliveryInfo'] as Map<String, dynamic>? ?? {}),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'deliveryInfo': deliveryInfo.toMap(),
      'createdAt': createdAt,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double quantityInKg;
  final double pricePerKg;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantityInKg,
    required this.pricePerKg,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantityInKg: (map['quantityInKg'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (map['pricePerKg'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantityInKg': quantityInKg,
      'pricePerKg': pricePerKg,
    };
  }
}
