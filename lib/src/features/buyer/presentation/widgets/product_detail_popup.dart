
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/services/cart_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailPopup extends StatefulWidget {
  final ProductListing product;

  const ProductDetailPopup({super.key, required this.product});

  @override
  State<ProductDetailPopup> createState() => _ProductDetailPopupState();
}

class _ProductDetailPopupState extends State<ProductDetailPopup> {
  double? _selectedQuantity;
  final List<double> _quantities = [1, 2, 3, 5, 10];

  void _addToCart() async {
    if (_selectedQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a quantity.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to your cart.')),
      );
      return;
    }

    final cartItem = CartItem(
      listingId: widget.product.id!,
      uuid: widget.product.uuid,
      farmerUID: widget.product.farmerUID,
      productName: widget.product.productName,
      quantityInKg: _selectedQuantity!,
      pricePerKg: widget.product.pricePerUnit,
      imageUrl: widget.product.productImageUrls.isNotEmpty ? widget.product.productImageUrls.first : '',
      buyerUID: user.uid,
    );

    try {
      await CartService().addToCart(cartItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to cart!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          if (isMobile) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SizedBox(
      width: 800,
      height: 500,
      child: Row(
        children: [
          Expanded(
            child: _buildProductImage(),
          ),
          Expanded(
            child: _buildProductDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SizedBox(
      width: 300,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 200, child: _buildProductImage()),
            _buildProductDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          // Using a placeholder as the user-provided image is not a URL
          image: const NetworkImage('https://placehold.co/400x500/E8F5E9/333?text=Product+Image'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.product.qualityGrade.toUpperCase(),
            style: const TextStyle(color: Colors.grey, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.productName,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '₹${widget.product.pricePerUnit.toStringAsFixed(2)} / kg',
            style: const TextStyle(fontSize: 24, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Text(
            widget.product.description,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 24),
          DropdownButton<double>(
            value: _selectedQuantity,
            hint: const Text('Select Quantity'),
            isExpanded: true,
            items: _quantities.map((double value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Text('$value kg'),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedQuantity = newValue;
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513), // Earthy color
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('ADD TO CART', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
