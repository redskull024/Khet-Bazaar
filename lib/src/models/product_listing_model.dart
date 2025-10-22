import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListing {
  final String? id;
  final String uuid;
  final String farmerUID;
  final String productName;
  final String emoji;
  final String productType;
  final bool isOrganic;
  final double quantityValue;
  final String quantityUnit;
  final String qualityGrade;
  final double pricePerUnit;
  final String description;
  final List<String> productImageUrls;
  final String farmerName;
  final String farmerPhoneNumber;
  final String farmerAddress;
  final String farmerState;
  final String farmerDistrict;
  final String farmerPincode;
  final String status;
  final int inquiries;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ProductListing({
    this.id,
    required this.uuid,
    required this.farmerUID,
    required this.productName,
    required this.emoji,
    required this.productType,
    required this.isOrganic,
    required this.quantityValue,
    required this.quantityUnit,
    required this.qualityGrade,
    required this.pricePerUnit,
    required this.description,
    this.productImageUrls = const [],
    required this.farmerName,
    required this.farmerPhoneNumber,
    required this.farmerAddress,
    required this.farmerState,
    required this.farmerDistrict,
    required this.farmerPincode,
    this.status = 'Active',
    this.inquiries = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'farmerUID': farmerUID,
      'productName': productName,
      'emoji': emoji,
      'productType': productType,
      'isOrganic': isOrganic,
      'quantityValue': quantityValue,
      'quantityUnit': quantityUnit,
      'qualityGrade': qualityGrade,
      'pricePerUnit': pricePerUnit,
      'description': description,
      'productImageUrls': productImageUrls,
      'farmerName': farmerName,
      'farmerPhoneNumber': farmerPhoneNumber,
      'farmerAddress': farmerAddress,
      'farmerState': farmerState,
      'farmerDistrict': farmerDistrict,
      'farmerPincode': farmerPincode,
      'status': status,
      'inquiries': inquiries,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ProductListing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductListing(
      id: doc.id,
      uuid: data['uuid'] ?? '',
      farmerUID: data['farmerUID'] ?? '',
      productName: data['productName'] ?? '',
      emoji: data['emoji'] ?? '❓',
      productType: data['productType'] ?? 'Other',
      isOrganic: data['isOrganic'] ?? false,
      quantityValue: (data['quantityValue'] as num?)?.toDouble() ?? 0.0,
      quantityUnit: data['quantityUnit'] ?? 'kg',
      qualityGrade: data['qualityGrade'] ?? 'A',
      pricePerUnit: (data['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      productImageUrls: List<String>.from(data['productImageUrls'] ?? []),
      farmerName: data['farmerName'] ?? '',
      farmerPhoneNumber: data['farmerPhoneNumber'] ?? '',
      farmerAddress: data['farmerAddress'] ?? '',
      farmerState: data['farmerState'] ?? '',
      farmerDistrict: data['farmerDistrict'] ?? '',
      farmerPincode: data['farmerPincode'] ?? '',
      status: data['status'] ?? 'Inactive',
      inquiries: (data['inquiries'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }
}
