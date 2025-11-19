import 'package:farm_connect/src/widgets/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/features/dashboard/buyer_dashboard_screen.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/models/delivery_info_model.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/services/cart_service.dart';
import 'package:farm_connect/src/services/listing_service.dart';
import 'package:farm_connect/src/services/purchase_service.dart';
import 'package:farm_connect/src/widgets/address_selection_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_connect/src/models/purchase_model.dart';
import 'package:uuid/uuid.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  bool _isPlacingOrder = false;

  Future<void> _placeOrder(List<CartItem> cartItems, DeliveryInfo address) async {
    if (_isPlacingOrder) return;

    setState(() {
      _isPlacingOrder = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final listingService = ListingService();
      final purchaseService = PurchaseService();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final buyerName = userDoc.data()?['name'] ?? 'Anonymous';

      // Group items by farmer
      final Map<String, List<CartItem>> itemsByFarmer = {};
      for (final item in cartItems) {
        final product = await listingService.getProductListing(item.listingId);
        if (product == null) {
          throw Exception('Product with ID ${item.listingId} not found.');
        }
        // Associate product with the cart item for later use
        item.productDetails = product;
        (itemsByFarmer[product.farmerUID] ??= []).add(item);
      }

      // Create one order per farmer using a transaction to ensure atomicity
      for (final farmerId in itemsByFarmer.keys) {
        final farmerItems = itemsByFarmer[farmerId]!;
        final totalAmount = farmerItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // For each item in the order, get the latest product data and update its quantity
          for (final item in farmerItems) {
            final productRef = FirebaseFirestore.instance.collection('product_listings').doc(item.listingId);
            final productDoc = await transaction.get(productRef);

            if (!productDoc.exists) {
              throw Exception("Product ${item.productName} does not exist anymore.");
            }

            final currentQuantity = (productDoc.data()!['quantityValue'] as num).toDouble();
            if (currentQuantity < item.totalQuantityInKg) {
              throw Exception("Not enough stock for ${item.productName}. Only $currentQuantity kg available.");
            }

            final newQuantity = currentQuantity - item.totalQuantityInKg;
            transaction.update(productRef, {
              'quantityValue': newQuantity,
              'status': newQuantity <= 0 ? 'Sold Out' : 'Available',
            });
          }

          // Create the order document
          final orderRef = FirebaseFirestore.instance.collection('orders').doc();
          transaction.set(orderRef, {
            'buyerUID': uid,
            'buyerName': buyerName,
            'farmerUID': farmerId,
            'items': farmerItems.map((item) => item.toMap()).toList(),
            'deliveryInfo': address.toMap(),
            'totalAmount': totalAmount,
            'status': 'Pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        });

        // After successful transaction, log each item to purchase_success collection
        for (final item in farmerItems) {
          final product = item.productDetails!;
          final purchase = PurchaseModel(
            uuid: product.uuid, // Use the product's original UUID
            productName: item.productName,
            farmerName: product.farmerName,
            farmerUID: product.farmerUID,
            buyerName: buyerName,
            listedDate: product.createdAt ?? Timestamp.now(),
            purchasedDate: Timestamp.now(),
            quantity: item.totalQuantityInKg.toInt(),
            perProductPrice: item.pricePerKg,
            totalPrice: item.totalPrice,
          );
          await purchaseService.savePurchase(purchase);
        }
      }

      await _cartService.clearCart();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(); // Close address popup
        context.go('/purchase-success');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar( // Show specific error
          SnackBar(content: Text('Error placing order: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: isDarkMode ? ThemeData.light() : Theme.of(context),
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: StreamBuilder<List<CartItem>>(
          stream: _cartService.getCartStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final cartItems = snapshot.data!;
            double subtotal = cartItems.fold(0, (sum, item) => sum + item.totalPrice);
            double shippingFee = 50.00; // Mock shipping fee
            double grandTotal = subtotal + shippingFee;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildCartItemCard(item);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildOrderSummary(subtotal, shippingFee, grandTotal),
                      const SizedBox(height: 24),
                      _buildActionButtons(cartItems),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.local_florist, color: Colors.green, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₹${item.pricePerKg.toStringAsFixed(2)}/kg', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildQuantityControls(item),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) { 
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () async {
            if (item.totalQuantityInKg > 1) {
              await _cartService.updateQuantity(item.id!, item.totalQuantityInKg - 1);
            } else {
              await _cartService.removeItem(item.id!);
            }
          },
        ),
        Text(
          '${item.totalQuantityInKg.toStringAsFixed(1)} kg',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: () async {
            try {
              final productDoc = await FirebaseFirestore.instance.collection('product_listings').doc(item.listingId).get();
              if (!productDoc.exists) throw Exception('Product not found');

              final availableStock = (productDoc.data()!['quantityValue'] as num).toDouble();
              if (item.totalQuantityInKg + 1 <= availableStock) {
                await _cartService.updateQuantity(item.id!, item.totalQuantityInKg + 1);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot add more. Only $availableStock kg available.'), backgroundColor: Colors.orange),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error checking stock: $e'), backgroundColor: Colors.red),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            _cartService.removeItem(item.id!);
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double subtotal, double shippingFee, double grandTotal) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _summaryRow('Shipping Fee', '₹${shippingFee.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _summaryRow('Grand Total', '₹${grandTotal.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(List<CartItem> cartItems) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isPlacingOrder
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddressSelectionPopup(
                        onAddressSelected: (address) {
                          _placeOrder(cartItems, address);
                        },
                      );
                    },
                  );
                },
          child: _isPlacingOrder
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: Colors.green[700]!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            context.go('/buyer-dashboard');
          },
          child: Text('Continue Purchasing', style: TextStyle(fontSize: 16, color: Colors.green[800])),
        ),
      ],
    );
  }
}