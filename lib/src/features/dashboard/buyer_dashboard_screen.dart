import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';

class AppColors {
  static const Color primaryDarkGreen = Color(0xFF1E463E);
  static const Color lightGreenNavBar = Color(0xFF8BC34A);
  static const Color earthyBrown = Color(0xFF8B4513);
  static const Color footerGreen = Color(0xFF38761D);
}

class BuyerDashboardScreen extends StatelessWidget {
  const BuyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: _CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _StoreTitle(),
            _FeatureBanners(),
            _ProductGrid(),
            _Footer(),
          ],
        ),
      ),
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
          color: AppColors.lightGreenNavBar,
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
                    IconButton(
                      icon: const Icon(Icons.logout),
                      color: AppColors.primaryDarkGreen,
                      tooltip: 'Logout',
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        context.go('/language-selection');
                      },
                    ),
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
                    PopupMenuItem(child: const Text('Logout'), onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      context.go('/language-selection');
                    }),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage('https://assets.website-files.com/627133f6eba4db0920eb3ce8/627d05a3b87098299ed10884_Products_hero.jpg'), fit: BoxFit.cover)),
      child: Container(
        color: AppColors.primaryDarkGreen.withOpacity(0.6),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('High quality organic products locally grown', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [_CategoryLink(text: 'FRUITS'), _CategoryLink(text: 'VEGETABLES')]),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryLink extends StatelessWidget {
  final String text;
  const _CategoryLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton(onPressed: () {}, child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
    );
  }
}

class _StoreTitle extends StatelessWidget {
  const _StoreTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      child: Column(
        children: const [
          Text('Explore Our Products', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Our Store', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
        ],
      ),
    );
  }
}

class _FeatureBanners extends StatelessWidget {
  const _FeatureBanners();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: const [
          _FeatureBanner(title: 'FRESH AND JUICY', imageUrl: 'https://static.vecteezy.com/system/resources/previews/020/619/698/non_2x/fruit-banner-on-wood-background-photo.jpg', isReversed: false),
          SizedBox(height: 24),
          _FeatureBanner(title: 'SAVOURY & CRUNCHY', imageUrl: 'https://tse4.mm.bing.net/th/id/OIP.DKnPlJYYtj1mOPl62f94tAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3', isReversed: true),
        ],
      ),
    );
  }
}

class _FeatureBanner extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isReversed;

  const _FeatureBanner({required this.title, required this.imageUrl, required this.isReversed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final List<Widget> children = [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen))),
        const SizedBox(width: 24, height: 24),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, height: 250, fit: BoxFit.cover))),
      ];

      if (constraints.maxWidth > 700) {
        return Row(children: isReversed ? children.reversed.toList() : children);
      } else {
        return Column(children: children);
      }
    });
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('product_listings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Something went wrong: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No products found.'));

          final products = snapshot.data!.docs.map((doc) => ProductListing.fromFirestore(doc)).toList();

          return LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = 3;
            if (constraints.maxWidth < 900) crossAxisCount = 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
              itemCount: products.length,
              itemBuilder: (context, index) => _ProductCard(product: products[index]),
            );
          });
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductListing product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    bool isSoldOut = product.status == 'Sold Out';
    return GestureDetector(
      onTap: isSoldOut ? null : () => context.push('/product-detail/${product.id!}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(product.productImageUrls.isNotEmpty ? product.productImageUrls.first : 'https://placehold.co/400x300/E8F5E9/333?text=Product'), fit: BoxFit.cover), color: Colors.grey[200]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('₹ ${product.pricePerUnit.toStringAsFixed(2)} INR', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Text('Available: ${product.quantityValue} ${product.quantityUnit}', style: const TextStyle(color: Color.fromARGB(137, 54, 210, 46), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            if (isSoldOut)
              Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: const Text('SOLD OUT', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
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