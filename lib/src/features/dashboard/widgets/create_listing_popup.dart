import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/services/listing_service.dart';

class CreateListingPopup extends StatefulWidget {
  const CreateListingPopup({Key? key}) : super(key: key);

  @override
  _CreateListingPopupState createState() => _CreateListingPopupState();
}

class _CreateListingPopupState extends State<CreateListingPopup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Controllers
  final _productNameCtrl = TextEditingController();
  final _quantityValueCtrl = TextEditingController();
  final _pricePerUnitCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _farmerNameCtrl = TextEditingController();
  final _farmerPhoneCtrl = TextEditingController();
  final _farmerAddressCtrl = TextEditingController();
  final _farmerStateCtrl = TextEditingController();
  final _farmerDistrictCtrl = TextEditingController();
  final _farmerPincodeCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController();

  // Form State
  String _productType = 'Fruit';
  String _quantityUnit = 'kg';
  String _qualityGrade = 'A';
  bool _isOrganic = false;
  final List<Uint8List> _productImages = [];

  @override
  void initState() {
    super.initState();
    _autoFillFarmerDetails();
  }

  Future<void> _autoFillFarmerDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _farmerNameCtrl.text = data['name'] ?? '';
        _farmerPhoneCtrl.text = data['phoneNumber'] ?? '';
        _farmerAddressCtrl.text = data['address'] ?? '';
        _farmerStateCtrl.text = data['state'] ?? '';
        _farmerDistrictCtrl.text = data['district'] ?? '';
        _farmerPincodeCtrl.text = data['pincode'] ?? '';
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    for (var file in pickedFiles) {
      _productImages.add(await file.readAsBytes());
    }
    setState(() {});
  }

  String _generateProductId(String productName) {
    final random = Random();
    final productCode = productName.length >= 2
        ? productName.substring(0, 2).toLowerCase()
        : productName.toLowerCase();
    final randomNumber = random.nextInt(10000).toString().padLeft(4, '0');
    return '$productCode$randomNumber';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final productId = _generateProductId(_productNameCtrl.text);

      final listing = ProductListing(
        uuid: productId,
        farmerUID: user.uid,
        productName: _productNameCtrl.text,
        productType: _productType,
        isOrganic: _isOrganic,
        emoji: _emojiCtrl.text,
        quantityValue: double.parse(_quantityValueCtrl.text),
        quantityUnit: _quantityUnit,
        qualityGrade: _qualityGrade,
        pricePerUnit: double.parse(_pricePerUnitCtrl.text),
        description: _descriptionCtrl.text,
        farmerName: _farmerNameCtrl.text,
        farmerPhoneNumber: _farmerPhoneCtrl.text,
        farmerAddress: _farmerAddressCtrl.text,
        farmerState: _farmerStateCtrl.text,
        farmerDistrict: _farmerDistrictCtrl.text,
        farmerPincode: _farmerPincodeCtrl.text,
      );

      await ListingService().createProductListing(listing, _productImages);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing created successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Listing'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: LayoutBuilder(builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 800;
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProductDetailsSection()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildFarmerDetailsSection()),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildProductDetailsSection(),
                          const SizedBox(height: 24),
                          _buildFarmerDetailsSection(),
                        ],
                      ),
                    );
                  }
                }),
              ),
            ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submitForm, child: const Text('Create Listing')),
      ],
    );
  }

  Widget _buildProductDetailsSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        TextFormField(controller: _productNameCtrl, decoration: const InputDecoration(labelText: 'Product Name *'), validator: (v) => v!.isEmpty ? 'Required' : null),
        TextFormField(controller: _emojiCtrl, decoration: const InputDecoration(labelText: 'Product Emoji (e.g., 🍎)')),
        DropdownButtonFormField<String>(
          value: _productType,
          decoration: const InputDecoration(labelText: 'Product Type'),
          items: ['Fruit', 'Vegetable'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _productType = v!),
        ),
        SwitchListTile(
          title: const Text('Is Organic?'),
          value: _isOrganic,
          onChanged: (v) => setState(() => _isOrganic = v),
        ),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _quantityValueCtrl, decoration: const InputDecoration(labelText: 'Quantity *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _quantityUnit,
              items: ['kg', 'quintal'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _quantityUnit = v!),
            ),
          ],
        ),
        DropdownButtonFormField<String>(
          value: _qualityGrade,
          decoration: const InputDecoration(labelText: 'Quality Grade'),
          items: ['A', 'B', 'C'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _qualityGrade = v!),
        ),
        TextFormField(controller: _pricePerUnitCtrl, decoration: const InputDecoration(labelText: 'Price per Unit (₹) *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
        TextFormField(controller: _descriptionCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
        const SizedBox(height: 16),
        OutlinedButton.icon(icon: const Icon(Icons.image), label: const Text('Upload Images'), onPressed: _pickImages),
        if (_productImages.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _productImages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.memory(_productImages[index], width: 80, height: 80, fit: BoxFit.cover),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFarmerDetailsSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Farmer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        TextFormField(controller: _farmerNameCtrl, decoration: const InputDecoration(labelText: 'Full Name *'), readOnly: true),
        TextFormField(controller: _farmerPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
        TextFormField(controller: _farmerAddressCtrl, decoration: const InputDecoration(labelText: 'Farm Address')),
        TextFormField(controller: _farmerStateCtrl, decoration: const InputDecoration(labelText: 'State')),
        TextFormField(controller: _farmerDistrictCtrl, decoration: const InputDecoration(labelText: 'District')),
        TextFormField(controller: _farmerPincodeCtrl, decoration: const InputDecoration(labelText: 'Pincode')),
      ],
    );
  }
}