import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_connect/src/models/purchase_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_connect/src/features/dashboard/widgets/sales_overview_widget.dart';

class FarmerAnalyzeScreen extends StatefulWidget {
  const FarmerAnalyzeScreen({Key? key}) : super(key: key);

  @override
  _FarmerAnalyzeScreenState createState() => _FarmerAnalyzeScreenState();
}

class _FarmerAnalyzeScreenState extends State<FarmerAnalyzeScreen> {
  // Define theme colors for this screen
  static const Color _primaryTextColor = Color(0xFF1E4D2B);
  static final Color _secondaryTextColor = Colors.grey[800]!;

  String? _userName;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  late Stream<List<PurchaseModel>> _purchaseSuccessStream;
  late Stream<QuerySnapshot> _farmerOrdersStream; // Kept for order status overview

  @override
  void initState() {
    super.initState();
    _fetchUserName();

    // Stream for real-time sales analytics from purchase_success collection
    _purchaseSuccessStream = FirebaseFirestore.instance
        .collection('purchase_success')
        .where('farmerUID', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PurchaseModel.fromMap(doc.data())).toList());

    // Stream for order status overview from orders collection
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return StreamBuilder<List<PurchaseModel>>(
          stream: _purchaseSuccessStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No sales data yet.'));
            }

            final purchases = snapshot.data!;
            final bool isDesktop = constraints.maxWidth > 900;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildMetricsGrid(purchases),
                  const SizedBox(height: 24),
                  isDesktop ? _buildDesktopLayout(purchases) : _buildMobileLayout(purchases),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard Overview',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userName != null ? 'Welcome back, $_userName!' : 'Welcome back!',
          style: TextStyle(fontSize: 16, color: _secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(List<PurchaseModel> purchases) {
    double totalRevenue = purchases.fold(0.0, (sum, item) => sum + item.totalPrice);
    double productsSold = purchases.fold(0.0, (sum, item) => sum + item.quantity);
    int totalOrders = purchases.length;

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildMetricCard('Total Revenue', totalRevenue, Icons.attach_money, const Color.fromARGB(255, 17, 61, 19), prefix: '₹'),
        _buildMetricCard('Total Orders', totalOrders.toDouble(), Icons.shopping_cart, const Color.fromARGB(255, 23, 79, 124)),
        _buildMetricCard('Products Sold (kg)', productsSold, Icons.local_shipping, const Color.fromARGB(255, 14, 85, 94)),
      ],
    );
  }

  Widget _buildDesktopLayout(List<PurchaseModel> purchases) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: SalesOverviewWidget(purchases: purchases)),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: Column(children: [_buildOrdersOverview(), const SizedBox(height: 24), _buildTopProducts(purchases)])),
      ],
    );
  }

  Widget _buildMobileLayout(List<PurchaseModel> purchases) {
    return Column(
      children: [
        SalesOverviewWidget(purchases: purchases),
        const SizedBox(height: 24),
        _buildOrdersOverview(),
        const SizedBox(height: 24),
        _buildTopProducts(purchases),
      ],
    );
  }

  Widget _buildMetricCard(String title, double value, IconData icon, Color color, {String prefix = ''}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color.withOpacity(0.9))),
                Icon(icon, color: color)
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$prefix${value.toStringAsFixed(title == 'Total Orders' ? 0 : 2)}',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
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
            const Text(
              'Orders Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTextColor),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _farmerOrdersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                int processing = 0, shipped = 0, pending = 0;
                for (var doc in snapshot.data!.docs) {
                  final status = (doc.data() as Map<String, dynamic>)['status'] as String?;
                  switch (status?.toLowerCase()) {
                    case 'processing':
                      processing++;
                      break;
                    case 'shipped':
                      shipped++;
                      break;
                    case 'pending':
                      pending++;
                      break;
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(status, style: TextStyle(fontSize: 16, color: _secondaryTextColor))
          ]),
          Text(count.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _secondaryTextColor))
        ],
      ),
    );
  }

  Widget _buildTopProducts(List<PurchaseModel> purchases) {
    Map<String, Map<String, dynamic>> productRevenues = {};
    for (var purchase in purchases) {
      productRevenues.update(purchase.uuid, (existing) {
        existing['revenue'] = (existing['revenue'] as double) + purchase.totalPrice;
        return existing;
      }, ifAbsent: () => {'name': purchase.productName, 'revenue': purchase.totalPrice});
    }
    final sortedProducts = productRevenues.entries.toList()..sort((a, b) => (b.value['revenue'] as double).compareTo(a.value['revenue'] as double));
    final topProducts = sortedProducts.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performing Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTextColor),
            ),
            const SizedBox(height: 16),
            if (topProducts.isEmpty)
              const Center(child: Text('No sales data available.'))
            else
              Column(
                children: topProducts
                    .map((product) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(product.value['name'] as String, style: TextStyle(fontSize: 16, color: _secondaryTextColor)),
                          Text('₹${(product.value['revenue'] as double).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _secondaryTextColor))
                        ])))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}