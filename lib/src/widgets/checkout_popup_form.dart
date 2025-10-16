
import 'package:farm_connect/src/models/delivery_info_model.dart';
import 'package:flutter/material.dart';

enum PaymentOption { stripe, razorpay }

/// A stateful widget for the checkout form, displayed as a modal dialog.
/// This form only collects data and returns a DeliveryInfo object on success.
class CheckoutPopupForm extends StatefulWidget {
  final double totalAmount;
  const CheckoutPopupForm({super.key, required this.totalAmount});

  @override
  State<CheckoutPopupForm> createState() => _CheckoutPopupFormState();
}

class _CheckoutPopupFormState extends State<CheckoutPopupForm> {
  final _formKey = GlobalKey<FormState>();
  PaymentOption? _paymentOption = PaymentOption.stripe;
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _pincodeController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final deliveryInfo = DeliveryInfo(
        fullName: _nameController.text,
        mobileNumber: _mobileController.text,
        addressLine1: _address1Controller.text,
        pincode: _pincodeController.text,
      );

      // Pop the dialog and return the collected information
      Navigator.of(context).pop(deliveryInfo);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _address1Controller.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Your Purchase'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your mobile number' : null,
              ),
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter your pincode' : null,
              ),
              const SizedBox(height: 24),
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<PaymentOption>(
                title: const Text('Stripe'),
                value: PaymentOption.stripe,
                groupValue: _paymentOption,
                onChanged: (PaymentOption? value) {
                  setState(() {
                    _paymentOption = value;
                  });
                },
              ),
              RadioListTile<PaymentOption>(
                title: const Text('Razorpay'),
                value: PaymentOption.razorpay,
                groupValue: _paymentOption,
                onChanged: (PaymentOption? value) {
                  setState(() {
                    _paymentOption = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
          child: Text('Pay ₹${widget.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
