import 'package:farm_connect/src/constants/app_colors.dart';
import 'package:farm_connect/src/widgets/app_bar.dart';
import 'package:farm_connect/src/widgets/footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productStream = FirebaseFirestore.instance.collection('product_listings').doc(productId).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: productStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        if (!snapshot.hasData || !snapshot.data!.exists) return const Scaffold(body: Center(child: Text('Product not found.')));

        final product = ProductListing.fromFirestore(snapshot.data!);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const CustomAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 700;
                    if (isMobile) {
                      return Column(
                        children: [
                          SizedBox(height: 300, child: _buildProductImage(product)),
                          const SizedBox(height: 24),
                          _ProductDetailsSection(product: product),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildProductImage(product)),
                          const SizedBox(width: 32),
                          Expanded(flex: 3, child: _ProductDetailsSection(product: product)),
                        ],
                      );
                    }
                  }),
                ),
                const Footer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(ProductListing product) {
    if (product.productImageUrls.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 50,
          ),
        ),
      );
    }

    return _ProductImageGallery(imageUrls: product.productImageUrls);
  }
}

class _ProductImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const _ProductImageGallery({required this.imageUrls});

  @override
  _ProductImageGalleryState createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null ? child : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red);
                },
              ),
            );
          },
        ),
        if (widget.imageUrls.length > 1) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _ProductImageIndicator(
                itemCount: widget.imageUrls.length,
                currentIndex: _currentPage,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductImageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const _ProductImageIndicator({required this.itemCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }
}

class _ProductDetailsSection extends ConsumerStatefulWidget {
  final ProductListing product;
  const _ProductDetailsSection({required this.product});

  @override
  ConsumerState<_ProductDetailsSection> createState() => _ProductDetailsSectionState();
}

class _ProductDetailsSectionState extends ConsumerState<_ProductDetailsSection> {
  double? _selectedQuantity;

  void _addToCart() async {
    final product = widget.product;
    if (_selectedQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a quantity.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in.')));
      return;
    }

    if (product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Product ID is missing.')));
      return;
    }

    final cartItem = CartItem(
      listingId: product.id!,
      productName: product.productName,
      totalQuantityInKg: _selectedQuantity!,
      pricePerKg: product.pricePerUnit,
      imageUrl: product.productImageUrls.isNotEmpty ? product.productImageUrls.first : '',
      buyerUID: user.uid,
    );

    try {
      await ref.read(cartNotifierProvider.notifier).addToCart(cartItem);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added to cart!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    bool isSoldOut = product.status == 'Sold Out';

    // Generate quantity options based on availability, up to a max of 10 for UI sanity.
    final List<double> quantities = [];
    if (!isSoldOut) {
      final maxQty = product.quantityValue < 10 ? product.quantityValue : 10.0;
      for (double i = 1; i <= maxQty; i++) {
        quantities.add(i);
      }
      if (product.quantityValue > 10) {
         // You might want to add a custom input for larger quantities later
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.qualityGrade.toUpperCase(), style: const TextStyle(color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(product.productName, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
        const SizedBox(height: 16),
        Text('₹${product.pricePerUnit.toStringAsFixed(2)} / ${product.quantityUnit}', style: const TextStyle(fontSize: 24, color: Colors.green)),
        const SizedBox(height: 8),
        Text(
          isSoldOut ? 'Sold Out' : 'Available: ${product.quantityValue} ${product.quantityUnit}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSoldOut ? Colors.red : Colors.black54),
        ),
        const SizedBox(height: 24),
        const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
        const SizedBox(height: 8),
        Text(product.description, style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 16)),
        const SizedBox(height: 32),
        if (!isSoldOut && quantities.isNotEmpty)
          DropdownButtonFormField<double>(
            value: _selectedQuantity,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Select Quantity'),
            hint: const Text('Select Quantity'),
            items: quantities.map((double value) => DropdownMenuItem<double>(value: value, child: Text('$value ${product.quantityUnit}'))).toList(),
            onChanged: (newValue) => setState(() => _selectedQuantity = newValue),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSoldOut ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSoldOut ? Colors.grey : AppColors.earthyBrown,
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(isSoldOut ? 'SOLD OUT' : 'ADD TO CART', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
