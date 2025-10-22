import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Random _random = Random();

  Future<void> createProductListing(ProductListing listing, List<Uint8List> images) async {
    try {
      // Upload images with a 60-second timeout.
      List<String> imageUrls = await _uploadImages(listing.farmerUID, images)
          .timeout(const Duration(seconds: 60), onTimeout: () => throw TimeoutException('Image upload took too long. Please check your network and Firebase Storage rules.'));

      ProductListing finalListing = _cloneListingWithImageUrls(listing, imageUrls);
      
      // Save to database with a 15-second timeout.
      await _firestore.collection('product_listings').add(finalListing.toMap())
          .timeout(const Duration(seconds: 15), onTimeout: () => throw TimeoutException('Database save timed out.'));

    } catch (e) {
      // Re-throw with a specific message to be handled by the UI.
      throw Exception('Error creating product listing: $e');
    }
  }

  Future<void> updateProductListing(String listingId, ProductListing listing, List<Uint8List> newImages) async {
    try {
      List<String> newImageUrls = await _uploadImages(listing.farmerUID, newImages)
        .timeout(const Duration(seconds: 60), onTimeout: () => throw TimeoutException('Image upload timed out.'));

      List<String> allImageUrls = List.from(listing.productImageUrls)..addAll(newImageUrls);
      ProductListing finalListing = _cloneListingWithImageUrls(listing, allImageUrls);
      
      await _firestore.collection('product_listings').doc(listingId).update(finalListing.toMap())
        .timeout(const Duration(seconds: 15), onTimeout: () => throw TimeoutException('Database update timed out.'));
    } catch (e) {
      throw Exception('Error updating product listing: $e');
    }
  }

  Future<List<String>> _uploadImages(String farmerUID, List<Uint8List> images) async {
    List<String> imageUrls = [];
    if (images.isEmpty) return imageUrls;

    for (final imageBytes in images) {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String randomPart = _random.nextInt(999999).toString().padLeft(6, '0');
      final String fileName = '${timestamp}_$randomPart';
      
      final Reference storageRef = _storage.ref().child('product_images').child(farmerUID).child(fileName);
      final UploadTask uploadTask = storageRef.putData(imageBytes);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  ProductListing _cloneListingWithImageUrls(ProductListing listing, List<String> imageUrls) {
    return ProductListing(
      uuid: listing.uuid,
      farmerUID: listing.farmerUID,
      productName: listing.productName,
      emoji: listing.emoji,
      productType: listing.productType,
      isOrganic: listing.isOrganic,
      quantityValue: listing.quantityValue,
      quantityUnit: listing.quantityUnit,
      qualityGrade: listing.qualityGrade,
      pricePerUnit: listing.pricePerUnit,
      description: listing.description,
      productImageUrls: imageUrls,
      farmerName: listing.farmerName,
      farmerPhoneNumber: listing.farmerPhoneNumber,
      farmerAddress: listing.farmerAddress,
      farmerState: listing.farmerState,
      farmerDistrict: listing.farmerDistrict,
      farmerPincode: listing.farmerPincode,
      id: listing.id,
      status: listing.status,
      inquiries: listing.inquiries,
      createdAt: listing.createdAt,
      updatedAt: listing.updatedAt,
    );
  }
}