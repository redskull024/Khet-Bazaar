import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/models/delivery_info_model.dart';
import 'package:farm_connect/src/models/purchase_model.dart';
import 'package:farm_connect/src/providers/cart_provider.dart';
import 'package:farm_connect/src/services/purchase_service.dart';
import 'package:farm_connect/src/widgets/address_selection_popup.dart';
import 'package:farm_connect/src/widgets/checkout_popup_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _processCheckout(BuildContext context, WidgetRef ref, double totalAmount, List<CartItem> cartItems) async {
    final deliveryInfo = await showDialog<DeliveryInfo>(
      context: context,
      builder: (BuildContext context) {
        return const AddressSelectionPopup();
      },
    );

    if (deliveryInfo == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Processing Order...")]),
        ),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('You must be logged in.');

      final firestore = FirebaseFirestore.instance;
      final purchaseService = PurchaseService();

      // Group cart items by farmerUID
      final Map<String, List<CartItem>> itemsByFarmer = {};
      for (final item in cartItems) {
        if (itemsByFarmer.containsKey(item.farmerUID)) {
          itemsByFarmer[item.farmerUID]!.add(item);
        } else {
          itemsByFarmer[item.farmerUID] = [item];
        }
      }

      await firestore.runTransaction((transaction) async {
        // For each farmer, create a separate order
        for (final farmerEntry in itemsByFarmer.entries) {
          final farmerId = farmerEntry.key;
          final farmerItems = farmerEntry.value;
          final farmerTotal = farmerItems.fold(0.0, (sum, item) => sum + item.totalPrice);

          // 1. Update product quantities for this farmer's items
          for (final item in farmerItems) {
            final productRef = firestore.collection('product_listings').doc(item.listingId);
            final productDoc = await transaction.get(productRef);

            if (!productDoc.exists) throw Exception('Product ${item.productName} not found!');

            final currentQuantity = (productDoc.data()!['quantityValue'] as num).toDouble();
            if (currentQuantity < item.quantityInKg) throw Exception('Not enough stock for ${item.productName}.');

            final newQuantity = currentQuantity - item.quantityInKg;
            
            if (newQuantity <= 0) {
              transaction.update(productRef, {'quantityValue': 0, 'status': 'Sold Out'});
            } else {
              transaction.update(productRef, {'quantityValue': newQuantity});
            }
          }

          // 2. Create the order document with a top-level farmerUID
          final orderRef = firestore.collection('orders').doc();
          transaction.set(orderRef, {
            'farmerUID': farmerId, // Add top-level farmerUID
            'buyerId': user.uid,
            'deliveryInfo': deliveryInfo.toMap(),
            'items': farmerItems.map((item) => item.toMap()).toList(),
            'totalAmount': farmerTotal,
            'status': 'Pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 3. Save purchase details to purchase_success table
          for (final item in farmerItems) {
            final productDoc = await firestore.collection('product_listings').doc(item.listingId).get();
            final farmerName = productDoc.data()!['farmerName'] ?? '';

            final purchase = PurchaseModel(
              uuid: item.uuid,
              productName: item.productName,
              farmerName: farmerName, // TODO: Get farmer name
              buyerName: user.displayName ?? 'Buyer Name',
              listedDate: item.timestamp ?? Timestamp.now(),
              purchasedDate: Timestamp.now(),
              quantity: item.quantityInKg.toInt(),
              perProductPrice: item.pricePerKg,
              totalPrice: item.totalPrice,
            );
            await purchaseService.savePurchase(purchase);
          }
        }
      });

      ref.read(cartNotifierProvider.notifier).clearCart();

      Navigator.of(context).pop(); // Close loading dialog
      context.go('/purchase-success');

    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsyncValue = ref.watch(cartNotifierProvider);
    final totalAmount = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: cartAsyncValue.when(
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
                        onLongPress: () => ref.read(cartNotifierProvider.notifier).removeFromCart(item.listingId),
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
                        onPressed: () => _processCheckout(context, ref, totalAmount, cartItems),
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