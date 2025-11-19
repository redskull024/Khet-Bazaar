
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/features/dashboard/widgets/edit_listing_popup.dart';

class FarmerProductListScreen extends StatelessWidget {
  const FarmerProductListScreen({super.key});

  void _showEditPopup(BuildContext context, ProductListing listing) {
    showDialog(
      context: context,
      builder: (_) => EditListingPopup(listing: listing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmerId = FirebaseAuth.instance.currentUser?.uid;

    if (farmerId == null) {
      return const Center(child: Text('Please log in to see your products.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('product_listings')
          .where('farmerUID', isEqualTo: farmerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'You have not listed any products yet.\nClick the \'Create Listing\' button to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final products = snapshot.data!.docs.map((doc) {
          return ProductListing.fromFirestore(doc);
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350.0,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: product.productImageUrls.isNotEmpty
                        ? Image.network(
                            product.productImageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.agriculture, size: 50, color: Colors.grey),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis), 
                        const SizedBox(height: 4),
                        Text('₹${product.pricePerUnit}/${product.quantityUnit}', style: TextStyle(fontSize: 16, color: Colors.green[800], fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(product.quantityValue > 0 ? 'Active' : 'Empty', style: const TextStyle(color: Colors.white)),
                          backgroundColor: product.quantityValue > 0 ? Colors.blue : Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      onPressed: () => _showEditPopup(context, product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
