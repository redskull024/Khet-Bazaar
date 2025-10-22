import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_connect/src/features/dashboard/widgets/sales_overview_widget.dart';
import 'package:farm_connect/src/features/dashboard/widgets/create_listing_popup.dart';
import 'package:go_router/go_router.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({Key? key}) : super(key: key);

  @override
  _FarmerDashboardScreenState createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  String? _userName;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  late Stream<QuerySnapshot> _farmerOrdersStream;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _farmerOrdersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('farmerUID', isEqualTo: _uid)
        .snapshots();
  }

  Future<void> _fetchUserName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (doc.exists && doc.data()!.containsKey('name')) {
        final name = doc.data()!['name'] as String;
        if (mounted) setState(() => _userName = name);
      }
    } catch (e) {
      // Handle or log error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildMetricsGrid(),
                const SizedBox(height: 24),
                isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              _userName != null ? 'Welcome back, $_userName!' : 'Welcome back!',
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(238, 0, 0, 0)),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create Listing'),
              onPressed: () => showDialog(context: context, builder: (_) => const CreateListingPopup()),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) context.go('/');
              },
              tooltip: 'Logout',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _farmerOrdersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load metrics.'));
        }
        if (!snapshot.hasData) return const Center(child: Text('No data.'));

        double totalRevenue = 0;
        double productsSold = 0;
        int totalOrders = snapshot.data!.docs.length;

        // Correctly loop through each order and then each item within the order
        for (var orderDoc in snapshot.data!.docs) {
          print(orderDoc.data());
          final orderData = orderDoc.data() as Map<String, dynamic>;
          final items = orderData['items'] as List<dynamic>? ?? [];
          for (var item in items) {
            final itemData = item as Map<String, dynamic>;
            final price = (itemData['pricePerKg'] as num?)?.toDouble() ?? 0.0;
            final quantity = (itemData['quantityInKg'] as num?)?.toDouble() ?? 0.0;
            totalRevenue += price * quantity;
            productsSold += quantity;
          }
        }

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildMetricCard('Total Revenue', totalRevenue, Icons.attach_money, const Color.fromARGB(130, 76, 175, 79), prefix: '₹'),
            _buildMetricCard('Total Orders', totalOrders.toDouble(), Icons.shopping_cart, const Color.fromARGB(130, 33, 149, 243)),
            _buildMetricCard('Products Sold (kg)', productsSold, Icons.local_shipping, const Color.fromARGB(130, 0, 187, 212)),
          ],
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: SalesOverviewWidget(uid: _uid)),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: Column(children: [_buildOrdersOverview(), const SizedBox(height: 24), _buildTopProducts()])),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        SalesOverviewWidget(uid: _uid),
        const SizedBox(height: 24),
        _buildOrdersOverview(),
        const SizedBox(height: 24),
        _buildTopProducts(),
      ],
    );
  }

  Widget _buildMetricCard(String title, double value, IconData icon, MaterialColor color, {String prefix = ''}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), Icon(icon, color: color.shade800)]),
            const SizedBox(height: 12),
            Text('$prefix${value.toStringAsFixed(title == 'Total Orders' ? 0 : 2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersOverview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Orders Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _farmerOrdersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                int processing = 0, shipped = 0, pending = 0;
                for (var doc in snapshot.data!.docs) {
                  final status = (doc.data() as Map<String, dynamic>)['status'] as String?;
                  switch (status?.toLowerCase()) {
                    case 'processing': processing++; break;
                    case 'shipped': shipped++; break;
                    case 'pending': pending++; break;
                  }
                }
                return Column(children: [
                  _buildOrderStatusItem('Processing', processing, Colors.orange),
                  _buildOrderStatusItem('Shipped', shipped, Colors.blue),
                  _buildOrderStatusItem('Pending', pending, Colors.grey),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusItem(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Text(status, style: const TextStyle(fontSize: 16))]), Text(count.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildTopProducts() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Performing Products (Overall)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                Map<String, Map<String, dynamic>> productRevenues = {};
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final items = data['items'] as List<dynamic>? ?? [];
                  for (var item in items) {
                    final itemData = item as Map<String, dynamic>;
                    final listingId = itemData['listingId'] as String?;
                    final name = itemData['productName'] as String? ?? 'Unknown';
                    final price = (itemData['pricePerKg'] as num?)?.toDouble() ?? 0.0;
                    final quantity = (itemData['quantityInKg'] as num?)?.toDouble() ?? 0.0;
                    if (listingId != null) {
                      productRevenues.update(listingId, (existing) {
                        existing['revenue'] = (existing['revenue'] as double) + (price * quantity);
                        return existing;
                      }, ifAbsent: () => {'name': name, 'revenue': price * quantity});
                    }
                  }
                }
                final sortedProducts = productRevenues.entries.toList()..sort((a, b) => (b.value['revenue'] as double).compareTo(a.value['revenue'] as double));
                final topProducts = sortedProducts.take(3).toList();
                if (topProducts.isEmpty) return const Center(child: Text('No sales data available.'));
                return Column(children: topProducts.map((product) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(product.value['name'] as String, style: const TextStyle(fontSize: 16)), Text('₹${(product.value['revenue'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]))).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}