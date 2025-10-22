import 'dart:async';
import 'package:farm_connect/src/models/delivery_info_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutPopupForm extends StatefulWidget {
  final double totalAmount;
  final DeliveryInfo deliveryInfo;

  const CheckoutPopupForm({super.key, required this.totalAmount, required this.deliveryInfo});

  @override
  State<CheckoutPopupForm> createState() => _CheckoutPopupFormState();
}

class _CheckoutPopupFormState extends State<CheckoutPopupForm> {

  void _processPayment() {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Processing Payment...")]),
        ),
      ),
    );

    // Simulate a 3-second payment processing delay
    Timer(const Duration(seconds: 3), () {
      // In a real app, here you would create the order in Firestore
      // then navigate.

      // Pop the loading dialog
      Navigator.of(context).pop(); 
      // Pop the checkout form itself
      Navigator.of(context).pop(); 

      // Navigate to the success page, replacing the cart page
      context.pushReplacement('/purchase-success');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Purchase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deliver to:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(widget.deliveryInfo.fullName),
          Text(widget.deliveryInfo.addressLine1),
          Text(widget.deliveryInfo.pincode),
          const Divider(height: 24),
          const Text('Payment Method: Simulation'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _processPayment,
          child: Text('Pay ₹${widget.totalAmount.toStringAsFixed(2)}'),
        ),
      ],
    );
  }
}
