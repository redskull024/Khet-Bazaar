
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';

/// Represents a unique product listing within the user's shopping cart.
///
/// This model simplifies cart management by ensuring that each document in the
/// Firestore `cart` subcollection corresponds to one unique product, regardless
/// of how many times it was added. The quantity is aggregated in the
/// [totalQuantityInKg] field.
class CartItem {
  /// The unique identifier for the cart item document in Firestore (e.g., 'cart_item_ABC').
  /// This is nullable because an ID may not exist for a new item that hasn't been saved yet.
  final String? id;

  /// The ID of the product listing this cart item refers to.
  final String listingId;

  /// The name of the product.
  final String productName;

  /// The aggregated total quantity of the product in the cart, measured in kilograms.
  double totalQuantityInKg;

  /// The price per kilogram of the product.
  final double pricePerKg;

  /// The URL for the product's image (or a placeholder).
  final String imageUrl;

  /// The UID of the buyer who owns this cart.
  final String buyerUID;

  // Not stored in Firestore, used for processing during checkout.
  ProductListing? productDetails;

  CartItem({
    this.id,
    required this.listingId,
    required this.productName,
    required this.totalQuantityInKg,
    required this.pricePerKg,
    required this.imageUrl,
    required this.buyerUID,
    this.productDetails,
  });

  /// Calculates the total price for this cart item.
  double get totalPrice => totalQuantityInKg * pricePerKg;

  /// Creates a [CartItem] instance from a Firestore document snapshot.
  /// The [documentId] is optional to allow creation from nested data (e.g., in an order).
  factory CartItem.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return CartItem(
      id: documentId,
      listingId: map['listingId'] ?? '',
      productName: map['productName'] ?? '',
      totalQuantityInKg: (map['totalQuantityInKg'] ?? 0.0).toDouble(),
      pricePerKg: (map['pricePerKg'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      buyerUID: map['buyerUID'] ?? '',
    );
  }

  /// Converts this [CartItem] instance into a map for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'productName': productName,
      'totalQuantityInKg': totalQuantityInKg,
      'pricePerKg': pricePerKg,
      'imageUrl': imageUrl,
      'buyerUID': buyerUID,
    };
  }
}
