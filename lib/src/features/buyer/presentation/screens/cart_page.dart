import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/models/delivery_info_model.dart';
import 'package:farm_connect/src/providers/cart_provider.dart';
import 'package:farm_connect/src/widgets/address_selection_popup.dart';
import 'package:farm_connect/src/widgets/checkout_popup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsyncValue = ref.watch(cartNotifierProvider);
    final totalAmount = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green[800],
      ),
      body: cartAsyncValue.when(
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty. Add some products!', style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        leading: item.imageUrl.isNotEmpty
                            ? Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.agriculture, color: Colors.green, size: 50),
                        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.quantityInKg} kg @ ₹${item.pricePerKg}/kg'),
                        trailing: Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('₹${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final selectedAddress = await showDialog<DeliveryInfo>(
                            context: context,
                            builder: (_) => const AddressSelectionPopup(),
                          );
                          if (selectedAddress != null && context.mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => CheckoutPopupForm(totalAmount: totalAmount, deliveryInfo: selectedAddress),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Proceed to Checkout', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}