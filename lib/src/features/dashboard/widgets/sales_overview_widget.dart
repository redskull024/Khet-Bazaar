import 'package:farm_connect/src/models/purchase_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class SalesOverviewWidget extends StatefulWidget {
  final List<PurchaseModel> purchases;

  const SalesOverviewWidget({Key? key, required this.purchases}) : super(key: key);

  @override
  _SalesOverviewWidgetState createState() => _SalesOverviewWidgetState();
}

class _SalesOverviewWidgetState extends State<SalesOverviewWidget> {
  String _salesPeriod = 'Daily';

  List<Map<String, dynamic>> _aggregateSales(List<PurchaseModel> purchases, String period) {
    Map<String, double> aggregatedData = {};
    DateTime now = DateTime.now();

    for (var purchase in purchases) {
      final timestamp = purchase.purchasedDate.toDate();
      final double revenue = purchase.totalPrice;

      if (period == 'Daily') {
        if (now.difference(timestamp).inDays < 7) {
          String day = DateFormat('E').format(timestamp); // MON, TUE, etc.
          aggregatedData.update(day, (value) => value + revenue, ifAbsent: () => revenue);
        }
      } else if (period == 'Weekly') {
        int weekDiff = now.difference(timestamp).inDays ~/ 7;
        if (weekDiff < 4) {
          String weekLabel = 'W${4 - weekDiff}';
          aggregatedData.update(weekLabel, (value) => value + revenue, ifAbsent: () => revenue);
        }
      } else if (period == 'Monthly') {
        if (now.year == timestamp.year && now.month - timestamp.month < 6) {
          String month = DateFormat('MMM').format(timestamp);
          aggregatedData.update(month, (value) => value + revenue, ifAbsent: () => revenue);
        }
      }
    }

    // Ensure order for daily and monthly for chart display
    if (period == 'Daily') {
      final sortedDays = {'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0};
      aggregatedData.forEach((key, value) {
        if(sortedDays.containsKey(key)) sortedDays[key] = value;
      });
      return sortedDays.entries.map((e) => {'label': e.key, 'value': e.value}).toList();
    }

    return aggregatedData.entries.map((e) => {'label': e.key, 'value': e.value}).toList();
  }

  @override
  Widget build(BuildContext context) {
    final salesData = _aggregateSales(widget.purchases, _salesPeriod);
    final maxValue = salesData.isNotEmpty ? (salesData.map((d) => d['value'] as num).reduce(max)).toDouble() : 0.0;

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
            if (salesData.isEmpty)
              const Center(heightFactor: 3, child: Text('No sales data for this period.'))
            else
              _buildChart(salesData, maxValue),
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