
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. The Notifier class for managing the cart state
class CartNotifier extends Notifier<List<CartItem>> {
  // The build method is called to create the initial state.
  @override
  List<CartItem> build() {
    return [];
  }

  /// Adds a product to the cart with a specified quantity.
  /// If the product already exists, it updates the quantity.
  void addToCart(ProductListing product, double quantity) {
    final existingItemIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      // If item exists, create a new list with the updated item.
      final updatedList = List<CartItem>.from(state);
      final existingItem = updatedList[existingItemIndex];
      updatedList[existingItemIndex] = CartItem(product: existingItem.product, quantity: existingItem.quantity + quantity);
      state = updatedList;
    } else {
      // Otherwise, create a new list with the new item added.
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  /// Removes an item from the cart.
  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Clears the entire cart.
  void clearCart() {
    state = [];
  }
}

// 2. The Provider that exposes the CartNotifier to the app.
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

// 3. A separate provider to compute the total price, which depends on the cartProvider.
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  // Use fold to sum up the total price of all items in the cart.
  return cart.fold(0, (total, item) => total + item.totalPrice);
});
