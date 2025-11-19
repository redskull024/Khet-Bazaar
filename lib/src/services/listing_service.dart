
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createProductListing(ProductListing listing, List<Uint8List> images) async {
    try {
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await _uploadImages(listing.uuid, images);
      }

      // Fetch farmer's name from the users collection to ensure it's accurate
      final userDoc = await _firestore.collection('users').doc(listing.farmerUID).get();
      final farmerName = (userDoc.data() as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown Farmer';



      final finalListing = ProductListing(
        id: listing.id,
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
        productImageUrls: imageUrls, // Use uploaded image URLs
        farmerName: farmerName,
        farmerPhoneNumber: listing.farmerPhoneNumber,
        farmerAddress: listing.farmerAddress,
        farmerState: listing.farmerState,
        farmerDistrict: listing.farmerDistrict,
        farmerPincode: listing.farmerPincode,
      );

      await _firestore.collection('product_listings').add(finalListing.toMap());
    } catch (e) {
      throw Exception('Error creating product listing: $e');
    }
  }

  Future<void> updateProductListing(ProductListing listing, List<Uint8List> newImages) async {
    if (listing.id == null) {
      throw Exception('Listing ID is required to update.');
    }

    try {
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        newImageUrls = await _uploadImages(listing.uuid, newImages);
      }

      // Combine old and new images
      final allImageUrls = [...listing.productImageUrls, ...newImageUrls];

      final finalListing = ProductListing(
        id: listing.id,
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
        productImageUrls: allImageUrls,
        farmerName: listing.farmerName,
        farmerPhoneNumber: listing.farmerPhoneNumber,
        farmerAddress: listing.farmerAddress,
        farmerState: listing.farmerState,
        farmerDistrict: listing.farmerDistrict,
        farmerPincode: listing.farmerPincode,
        createdAt: listing.createdAt, // Preserve original creation date
      );

      await _firestore.collection('product_listings').doc(listing.id).update(finalListing.toMap());
    } catch (e) {
      throw Exception('Error updating product listing: $e');
    }
  }

  Future<List<String>> _uploadImages(String productId, List<Uint8List> images) async {
    List<String> imageUrls = [];
    for (var i = 0; i < images.length; i++) {
      final ref = _storage.ref().child('product_images/$productId/image_$i.jpg');
      final uploadTask = ref.putData(images[i], SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<ProductListing> getProductListing(String listingId) async {
    try {
      final doc = await _firestore.collection('product_listings').doc(listingId).get();
      return ProductListing.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error fetching product listing: $e');
    }
  }
}
