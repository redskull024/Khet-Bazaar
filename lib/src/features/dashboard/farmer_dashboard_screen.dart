
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/features/auth/auth_service.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ProductListing>>? _listingsStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _listingsStream = _firestore
          .collection('product_listings')
          .where('farmerUID', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductListing.fromFirestore(doc))
              .toList());
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark theme background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        title: Row(
          children: [
            // Assuming you have a logo in assets
            Image.asset('assets/images/logo.png', height: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.agriculture, color: Colors.white)),
            const SizedBox(width: 12),
            const Text('FarmConnect', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          const Center(
            child: Text(
              'Welcome, Sudeep', // Placeholder name
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 32),
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Farmer Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => context.push('/create-listing'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create New Listing'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: const [
        Expanded(child: _SummaryCard(title: 'Active Listings', value: '2', icon: Icons.list_alt, color: Colors.blue)),
        SizedBox(width: 20),
        Expanded(child: _SummaryCard(title: 'Total Inquiries', value: '16', icon: Icons.question_answer, color: Colors.orange)),
        SizedBox(width: 20),
        Expanded(child: _SummaryCard(title: 'Products Sold', value: '1', icon: Icons.check_circle, color: Colors.teal)),
      ],
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Product Listings',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 22, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: StreamBuilder<List<ProductListing>>(
            stream: _listingsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('You have no product listings.', style: TextStyle(color: Colors.white70)),
                  ),
                );
              }

              final listings = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listings.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFF333333), height: 1),
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return _buildProductRow(listing);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow(ProductListing listing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(listing.productName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Center(child: _StatusChip(status: listing.status))),
          Expanded(flex: 3, child: Center(child: Text('₹${listing.pricePerUnit}/${listing.quantityUnit}', style: const TextStyle(color: Colors.white70)))),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: () => context.push('/edit-listing/${listing.id}'), icon: const Icon(Icons.edit, color: Colors.orange, size: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title; 
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light green background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Active' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status == 'Active' ? Colors.green : Colors.orange, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(color: status == 'Active' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
