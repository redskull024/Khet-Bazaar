
import 'package:farm_connect/src/models/product_listing_model.dart';

/// Represents a single item in the shopping cart.
class CartItem {
  final ProductListing product;
  final double quantity;

  CartItem({required this.product, required this.quantity});

  /// Method to calculate the total price for this cart item.
  double get totalPrice => product.pricePerUnit * quantity;

  /// Converts the [CartItem] instance to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  /// Factory constructor to create a [CartItem] from a map.
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: ProductListing.fromMap(map['product']), // Assumes ProductListing has fromMap
      quantity: (map['quantity'] as num).toDouble(),
    );
  }
}
