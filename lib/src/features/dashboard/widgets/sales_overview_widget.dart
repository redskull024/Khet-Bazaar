import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class SalesOverviewWidget extends StatefulWidget {
  final String uid;

  const SalesOverviewWidget({Key? key, required this.uid}) : super(key: key);

  @override
  _SalesOverviewWidgetState createState() => _SalesOverviewWidgetState();
}

class _SalesOverviewWidgetState extends State<SalesOverviewWidget> {
  String _salesPeriod = 'Daily';

  // This stream now listens to the orders and maps them to the aggregated data structure.
  Stream<List<Map<String, dynamic>>> _getAggregatedSalesStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('farmerUID', isEqualTo: widget.uid)
        .snapshots()
        .map((snapshot) {
      return _aggregateSales(snapshot.docs, _salesPeriod);
    });
  }

  // This function now correctly processes the nested items array in each order.
  List<Map<String, dynamic>> _aggregateSales(List<QueryDocumentSnapshot> orderDocs, String period) {
    Map<String, double> aggregatedData = {};
    DateTime now = DateTime.now();

    for (var orderDoc in orderDocs) {
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final timestamp = (orderData['createdAt'] as Timestamp?)?.toDate();
      if (timestamp == null) continue;

      final items = orderData['items'] as List<dynamic>? ?? [];
      double orderRevenue = 0;
      for (var item in items) {
        final itemData = item as Map<String, dynamic>;
        final price = (itemData['pricePerKg'] as num?)?.toDouble() ?? 0.0;
        final quantity = (itemData['quantityInKg'] as num?)?.toDouble() ?? 0.0;
        orderRevenue += price * quantity;
      }

      // Group the calculated revenue by the selected time period.
      if (period == 'Daily') {
        if (now.difference(timestamp).inDays < 7) {
          String day = DateFormat('E').format(timestamp); // MON, TUE, etc.
          aggregatedData.update(day, (value) => value + orderRevenue, ifAbsent: () => orderRevenue);
        }
      } else if (period == 'Weekly') {
        int weekDiff = now.difference(timestamp).inDays ~/ 7;
        if (weekDiff < 4) {
          String weekLabel = 'W${4 - weekDiff}';
           aggregatedData.update(weekLabel, (value) => value + orderRevenue, ifAbsent: () => orderRevenue);
        }
      } else if (period == 'Monthly') {
        if (now.year == timestamp.year && now.month - timestamp.month < 6) {
          String month = DateFormat('MMM').format(timestamp);
          aggregatedData.update(month, (value) => value + orderRevenue, ifAbsent: () => orderRevenue);
        }
      }
    }

    return aggregatedData.entries.map((e) => {'label': e.key, 'value': e.value}).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sales Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildToggleButtons(),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getAggregatedSalesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(heightFactor: 3, child: Text('No sales data for this period.'));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final salesData = snapshot.data!;
                final maxValue = salesData.isNotEmpty ? (salesData.map((d) => d['value'] as num).reduce(max)).toDouble() : 0.0;

                return _buildChart(salesData, maxValue);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return ToggleButtons(
      isSelected: [_salesPeriod == 'Daily', _salesPeriod == 'Weekly', _salesPeriod == 'Monthly'],
      onPressed: (index) {
        setState(() {
          if (index == 0) _salesPeriod = 'Daily';
          if (index == 1) _salesPeriod = 'Weekly';
          if (index == 2) _salesPeriod = 'Monthly';
        });
      },
      borderRadius: BorderRadius.circular(8),
      children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Daily')), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Weekly')), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Monthly'))],
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> data, double maxValue) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildYAxis(maxValue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((d) => _buildBar(d['value'], maxValue)).toList(),
                  ),
                ),
                const Divider(thickness: 1, height: 1),
                SizedBox(
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: data.map((d) => Text(d['label'] as String)).toList(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double value, double maxValue) {
    final barHeight = (value / (maxValue == 0 ? 1 : maxValue)) * 150;
    return Flexible(child: Container(height: barHeight > 0 ? barHeight : 0, width: 20, color: Colors.purple.shade300));
  }

  Widget _buildYAxis(double maxValue) {
    if (maxValue == 0) return const Text('0');
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final value = maxValue * (1 - (index / 4));
        return Text(value.toStringAsFixed(0));
      }),
    );
  }
}
