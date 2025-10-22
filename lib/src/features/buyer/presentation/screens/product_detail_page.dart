import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/models/cart_item_model.dart';
import 'package:farm_connect/src/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AppColors {
  static const Color primaryDarkGreen = Color(0xFF1E463E);
  static const Color earthyBrown = Color(0xFF8B4513);
  static const Color footerGreen = Color(0xFF38761D);
}

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
          appBar: _CustomAppBar(),
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
                _Footer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(ProductListing product) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(product.productImageUrls.isNotEmpty
              ? product.productImageUrls.first
              : 'https://placehold.co/600x400/E8F5E9/333?text=Product+Image'),
          fit: BoxFit.cover,
        ),
      ),
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
  final List<double> _quantities = [1, 2, 3, 5, 10];

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
      uuid: product.uuid,
      farmerUID: product.farmerUID,
      productName: product.productName,
      quantityInKg: _selectedQuantity!,
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
        if (!isSoldOut)
          DropdownButtonFormField<double>(
            value: _selectedQuantity,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Select Quantity'),
            hint: const Text('Select Quantity'),
            items: _quantities.map((double value) => DropdownMenuItem<double>(value: value, child: Text('$value ${product.quantityUnit}'))).toList(),
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

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('KhetBazaar', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 24, fontWeight: FontWeight.bold)),
              if (!isMobile)
                Row(
                  children: [
                    const _AppBarLink(text: 'About Us'),
                    const _AppBarLink(text: 'Our Farm'),
                    const _AppBarLink(text: 'Products'),
                    IconButton(icon: const FaIcon(FontAwesomeIcons.cartShopping), color: AppColors.primaryDarkGreen, onPressed: () => context.go('/cart')),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.earthyBrown,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text('CONTACT', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              else
                PopupMenuButton(
                  icon: const Icon(Icons.menu, color: AppColors.primaryDarkGreen),
                  itemBuilder: (context) => [
                    const PopupMenuItem(child: Text('About Us')),
                    const PopupMenuItem(child: Text('Our Farm')),
                    const PopupMenuItem(child: Text('Products')),
                    PopupMenuItem(child: const Text('Cart'), onTap: () => context.go('/cart')),
                    const PopupMenuItem(child: Text('CONTACT')),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AppBarLink extends StatelessWidget {
  final String text;
  const _AppBarLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: AppColors.primaryDarkGreen, fontSize: 16)),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: AppColors.footerGreen,
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _FooterInfo()),
              Expanded(child: _FooterLinks(title: 'Navigation', links: {'About Us': '#', 'Our Farm': '#', 'Products': '#'})),
              Expanded(child: _FooterLinks(title: 'Socials', links: {'Facebook': '#', 'Twitter': '#', 'Instagram': '#'})),
            ],
          );
        } else {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FooterInfo(),
              SizedBox(height: 30),
              _FooterLinks(title: 'Navigation', links: {'About Us': '#', 'Our Farm': '#', 'Products': '#'}),
              SizedBox(height: 30),
              _FooterLinks(title: 'Socials', links: {'Facebook': '#', 'Twitter': '#', 'Instagram': '#'}),
            ],
          );
        }
      }),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('KhetBazaar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Connecting farmers directly with buyers for fresh produce, fair prices, and sustainable farming.', style: TextStyle(color: Colors.white70, height: 1.5)),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final Map<String, String> links;
  const _FooterLinks({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...links.entries.map((entry) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: InkWell(onTap: () {}, child: Text(entry.key, style: const TextStyle(color: Colors.white70))))),
      ],
    );
  }
}
