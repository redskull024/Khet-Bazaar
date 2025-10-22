import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryDetailsPopup extends StatefulWidget {
  const DeliveryDetailsPopup({Key? key}) : super(key: key);

  @override
  _DeliveryDetailsPopupState createState() => _DeliveryDetailsPopupState();
}

class _DeliveryDetailsPopupState extends State<DeliveryDetailsPopup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _autoFillUserDetails();
  }

  Future<void> _autoFillUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _nameCtrl.text = data['name'] ?? '';
          _phoneCtrl.text = data['phoneNumber'] ?? user.phoneNumber ?? '';
          _addressCtrl.text = data['address'] ?? '';
          _cityCtrl.text = data['city'] ?? '';
          _stateCtrl.text = data['state'] ?? '';
          _pincodeCtrl.text = data['pincode'] ?? '';
        });
      }
    } catch (e) {
      // Handle or log error
    }
  }

  void _confirmOrder() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would now:
      // 1. Create a DeliveryInfo object from the controllers.
      // 2. Get all items from the CartService.
      // 3. Create one or more 'order' documents in Firestore with the cart items and delivery info.
      // 4. Clear the user's cart.
      // 5. Navigate to a purchase success page.

      // For now, we just show a success message and close the dialogs.
      Navigator.of(context).pop(); // Close delivery popup
      Navigator.of(context).pop(); // Close cart page if it's also a popup, or use context.go()
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully! (Simulation)'), backgroundColor: Colors.blue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Delivery Details'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                    TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                    TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address'), validator: (v) => v!.isEmpty ? 'Required' : null),
                    TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City'), validator: (v) => v!.isEmpty ? 'Required' : null),
                    TextFormField(controller: _stateCtrl, decoration: const InputDecoration(labelText: 'State'), validator: (v) => v!.isEmpty ? 'Required' : null),
                    TextFormField(controller: _pincodeCtrl, decoration: const InputDecoration(labelText: 'Pincode'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _confirmOrder, child: const Text('Confirm Order')),
      ],
    );
  }
}
