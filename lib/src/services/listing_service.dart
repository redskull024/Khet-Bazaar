
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> _uploadImage(File image, String listingId) async {
    final ref = _storage.ref().child('product_images').child(listingId).child(DateTime.now().toIso8601String());
    final uploadTask = await ref.putFile(image);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> createProductListing(ProductListing listing, List<File> images) async {
    try {
      final docRef = _firestore.collection('product_listings').doc();
      
      List<String> imageUrls = [];
      for (var image in images) {
        imageUrls.add(await _uploadImage(image, docRef.id));
      }

      final newListing = ProductListing(
        id: docRef.id,
        productName: listing.productName,
        description: listing.description,
        productImageUrls: imageUrls,
        pricePerUnit: listing.pricePerUnit,
        quantityUnit: listing.quantityUnit,
        quantityValue: listing.quantityValue,
        qualityGrade: listing.qualityGrade,
        farmerName: listing.farmerName,
        farmerAddress: listing.farmerAddress,
        farmerDistrict: listing.farmerDistrict,
        farmerState: listing.farmerState,
        farmerPincode: listing.farmerPincode,
        farmerPhoneNumber: listing.farmerPhoneNumber,
        farmerUID: listing.farmerUID,
        status: listing.status,
        inquiries: listing.inquiries,
        createdAt: listing.createdAt,
        updatedAt: listing.updatedAt,
      );

      await docRef.set(newListing.toMap());
    } catch (e) {
      print('Error creating product listing: $e');
      rethrow;
    }
  }

  Future<void> updateProductListing(String listingId, ProductListing listing, List<File> images) async {
    try {
      List<String> imageUrls = List.from(listing.productImageUrls); // Keep existing images
      // Upload new images if any
      for (var image in images) {
        imageUrls.add(await _uploadImage(image, listingId));
      }

      final updatedListing = ProductListing(
        id: listingId,
        productName: listing.productName,
        description: listing.description,
        productImageUrls: imageUrls, // New and existing images
        pricePerUnit: listing.pricePerUnit,
        quantityUnit: listing.quantityUnit,
        quantityValue: listing.quantityValue,
        qualityGrade: listing.qualityGrade,
        farmerName: listing.farmerName,
        farmerAddress: listing.farmerAddress,
        farmerDistrict: listing.farmerDistrict,
        farmerState: listing.farmerState,
        farmerPincode: listing.farmerPincode,
        farmerPhoneNumber: listing.farmerPhoneNumber,
        farmerUID: listing.farmerUID,
        status: listing.status,
        inquiries: listing.inquiries,
        createdAt: listing.createdAt, // Keep original creation date
        updatedAt: Timestamp.now(), // Update the timestamp
      );

      await _firestore.collection('product_listings').doc(listingId).update(updatedListing.toMap());
    } catch (e) {
      print('Error updating product listing: $e');
      rethrow;
    }
  }
}
