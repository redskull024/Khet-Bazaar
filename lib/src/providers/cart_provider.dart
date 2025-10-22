import 'dart:async';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/services/cart_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartServiceProvider = Provider<CartService>((ref) => CartService());

final cartStreamProvider = StreamProvider<List<CartItem>>((ref) {
  final cartService = ref.watch(cartServiceProvider);
  return cartService.getCartStream();
});

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  FutureOr<List<CartItem>> build() {
    return ref.watch(cartStreamProvider.future);
  }

  Future<void> addToCart(CartItem item) async {
    final cartService = ref.read(cartServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await cartService.addToCart(item);
      return ref.watch(cartStreamProvider.future);
    });
  }

  Future<void> removeFromCart(String listingId) async {
    final cartService = ref.read(cartServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await cartService.removeFromCart(listingId);
      return ref.watch(cartStreamProvider.future);
    });
  }

  Future<void> clearCart() async {
    final cartService = ref.read(cartServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await cartService.clearCart();
      return [];
    });
  }
}

final cartNotifierProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  final cartAsyncValue = ref.watch(cartNotifierProvider);
  return cartAsyncValue.when(
    data: (cart) => cart.fold(0, (total, item) => total + item.totalPrice),
    loading: () => 0,
    error: (_, __) => 0,
  );
});