
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/models/delivery_info_model.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final Timestamp createdAt;
  final DeliveryInfo deliveryInfo;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.deliveryInfo,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    var itemsList = data['items'] as List;
    List<CartItem> items = itemsList.map((i) => CartItem.fromMap(i)).toList();

    return OrderModel(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      items: items,
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'] ?? 'Unknown',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      deliveryInfo: DeliveryInfo.fromMap(data['deliveryInfo']),
    );
  }
}
