import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified model class for a product listing.
class ProductListing {
  final String id;
  final String productName;
  final String description;
  final List<String> productImageUrls;
  final double pricePerUnit;
  final String quantityUnit;
  final double quantityValue;
  final String qualityGrade;
  final String farmerName;
  final String farmerAddress;
  final String farmerDistrict;
  final String farmerState;
  final String farmerPincode;
  final String farmerPhoneNumber;
  final String farmerUID;
  final String status;
  final int inquiries;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductListing({
    required this.id,
    required this.productName,
    required this.description,
    required this.productImageUrls,
    required this.pricePerUnit,
    required this.quantityUnit,
    required this.quantityValue,
    required this.qualityGrade,
    required this.farmerName,
    required this.farmerAddress,
    required this.farmerDistrict,
    required this.farmerState,
    required this.farmerPincode,
    required this.farmerPhoneNumber,
    required this.farmerUID,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'Pending',
    this.inquiries = 0,
  });

  /// Factory constructor to create a [ProductListing] from a Firestore document.
  factory ProductListing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductListing.fromMap(data, id: doc.id);
  }

  /// Factory constructor to create a [ProductListing] from a map.
  factory ProductListing.fromMap(Map<String, dynamic> data, {String? id}) {
     return ProductListing(
      id: id ?? data['id'] ?? '',
      productName: data['productName'] ?? '',
      description: data['description'] ?? '',
      productImageUrls: List<String>.from(data['productImageUrls'] ?? []),
      pricePerUnit: (data['pricePerUnit'] ?? 0).toDouble(),
      quantityUnit: data['quantityUnit'] ?? 'kg',
      quantityValue: (data['quantityValue'] ?? 0).toDouble(),
      qualityGrade: data['qualityGrade'] ?? 'N/A',
      farmerName: data['farmerName'] ?? 'Unknown Farmer',
      farmerAddress: data['farmerAddress'] ?? 'Unknown Address',
      farmerDistrict: data['farmerDistrict'] ?? 'Unknown District',
      farmerState: data['farmerState'] ?? 'Unknown State',
      farmerPincode: data['farmerPincode'] ?? '',
      farmerPhoneNumber: data['farmerPhoneNumber'] ?? '',
      farmerUID: data['farmerUID'] ?? '',
      status: data['status'] ?? 'Pending',
      inquiries: data['inquiries'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// Converts the [ProductListing] instance to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'description': description,
      'productImageUrls': productImageUrls,
      'pricePerUnit': pricePerUnit,
      'quantityUnit': quantityUnit,
      'quantityValue': quantityValue,
      'qualityGrade': qualityGrade,
      'farmerName': farmerName,
      'farmerAddress': farmerAddress,
      'farmerDistrict': farmerDistrict,
      'farmerState': farmerState,
      'farmerPincode': farmerPincode,
      'farmerPhoneNumber': farmerPhoneNumber,
      'farmerUID': farmerUID,
      'status': status,
      'inquiries': inquiries,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}