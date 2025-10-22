import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryInfo {
  final String? id;
  final String fullName;
  final String mobileNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;

  DeliveryInfo({
    this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
  });

  // Factory for creating from a DocumentSnapshot
  factory DeliveryInfo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DeliveryInfo.fromMap(data, id: doc.id);
  }

  // Factory for creating from a Map (used for nested objects)
  factory DeliveryInfo.fromMap(Map<String, dynamic> data, {String? id}) {
    return DeliveryInfo(
      id: id,
      fullName: data['fullName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      addressLine1: data['addressLine1'] ?? '',
      addressLine2: data['addressLine2'],
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
