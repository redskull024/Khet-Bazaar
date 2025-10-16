import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/features/auth/auth_service.dart';
import 'package:farm_connect/src/features/auth/login_page.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BuyerDashboardScreen extends ConsumerWidget {
  const BuyerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('FarmConnect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text("Welcome, Sudeep", style: TextStyle(color: Colors.white, fontSize: 16))),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  context.push('/cart');
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cart.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().signOut();
              // This is an exception where we don't want to use go_router's context,
              // as it might be invalid after sign out.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buyer Dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Browse products from farmers across the country.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('product_listings').where('status', isEqualTo: 'Active').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products available at the moment.'));
        }

        final products = snapshot.data!.docs.map((doc) => ProductListing.fromFirestore(doc)).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.55, // Adjusted for new text
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductListing product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('₹${product.pricePerUnit}/${product.quantityUnit}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[700])),
                  const SizedBox(height: 4),
                  Text('Available: ${product.quantityValue} ${product.quantityUnit}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer(
                      builder: (context, ref, child) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            _showQuantityDialog(context, product, ref);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                          label: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 12)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, ProductListing product, WidgetRef ref) {
    final quantityController = TextEditingController();
    final cart = ref.read(cartProvider);
    final itemInCart = cart.firstWhere((item) => item.product.id == product.id, orElse: () => CartItem(product: product, quantity: 0));
    final availableQuantity = product.quantityValue - itemInCart.quantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Quantity for ${product.productName}'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Max: $availableQuantity ${product.quantityUnit}'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = double.tryParse(quantityController.text);
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid quantity')),
                  );
                  return;
                }
                if (quantity > availableQuantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Only $availableQuantity ${product.quantityUnit} available')),
                  );
                  return;
                }
                ref.read(cartProvider.notifier).addToCart(product, quantity);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${product.productName} to cart')),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }
}