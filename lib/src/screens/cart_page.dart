
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/delivery_info_model.dart';
import 'package:farm_connect/src/providers/cart_provider.dart';
import 'package:farm_connect/src/widgets/checkout_popup_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _processCheckout(BuildContext context, WidgetRef ref, double totalAmount) async {
    // 1. Show the checkout form to collect delivery info
    final deliveryInfo = await showDialog<DeliveryInfo>(
      context: context,
      builder: (BuildContext context) {
        return CheckoutPopupForm(totalAmount: totalAmount);
      },
    );

    // If the user cancelled the dialog, do nothing
    if (deliveryInfo == null) return;

    // 2. Show a loading dialog while processing the order
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Processing Order...")],
          ),
        ),
      ),
    );

    try {
      final cartItems = ref.read(cartProvider);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('You must be logged in.');

      final firestore = FirebaseFirestore.instance;

      // 3. Run a transaction to update stock and create the order
      await firestore.runTransaction((transaction) async {
        for (final item in cartItems) {
          final productRef = firestore.collection('product_listings').doc(item.product.id);
          final productDoc = await transaction.get(productRef);

          if (!productDoc.exists) throw Exception('Product ${item.product.productName} not found!');

          final currentQuantity = (productDoc.data()!['quantityValue'] as num).toDouble();
          if (currentQuantity < item.quantity) throw Exception('Not enough stock for ${item.product.productName}.');

          final newQuantity = currentQuantity - item.quantity;
          transaction.update(productRef, {'quantityValue': newQuantity});
        }

        final orderRef = firestore.collection('orders').doc();
        transaction.set(orderRef, {
          'buyerId': user.uid,
          'deliveryInfo': {
            'fullName': deliveryInfo.fullName,
            'mobileNumber': deliveryInfo.mobileNumber,
            'addressLine1': deliveryInfo.addressLine1,
            'pincode': deliveryInfo.pincode,
          },
          'items': cartItems.map((item) => item.toMap()).toList(),
          'totalAmount': totalAmount,
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // 4. Clear the local cart state
      ref.read(cartProvider.notifier).clearCart();

      // 5. Close loading dialog and navigate to success page
      Navigator.of(context).pop(); // Close loading dialog
      context.go('/purchase-success');

    } catch (e) {
      // On failure, close loading dialog and show an error message
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green[800],
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty. Add some products!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
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
                          leading: Icon(Icons.agriculture, color: Colors.green[700]),
                          title: Text(item.product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.quantity} ${item.product.quantityUnit} @ ₹${item.product.pricePerUnit}/${item.product.quantityUnit}'),
                          trailing: Text(
                            '₹${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onLongPress: () {
                            ref.read(cartProvider.notifier).removeFromCart(item.product.id);
                          },
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
                          onPressed: () => _processCheckout(context, ref, totalAmount),
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
            ),
    );
  }
}
