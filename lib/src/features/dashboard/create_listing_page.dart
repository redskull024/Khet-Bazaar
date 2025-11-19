import 'dart:math';
import 'dart:typed_data';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/services/listing_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateListingPage extends StatefulWidget {
  final String? listingId;
  const CreateListingPage({Key? key, this.listingId}) : super(key: key);

  @override
  _CreateListingPageState createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final ListingService _listingService = ListingService();
  bool _isLoading = false;
  bool get _isEditMode => widget.listingId != null;

  // Controllers
  final _productNameController = TextEditingController();
  final _quantityValueController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _farmerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _emojiController = TextEditingController();

  // State variables
  String _productType = 'Fruit';
  bool _isOrganic = false;
  String _quantityUnit = 'kg';
  String _qualityGrade = 'A';
  final List<Uint8List> _selectedImages = [];
  List<String> _existingImageUrls = [];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _fetchListingDetails();
    } else {
      _fetchUserData();
    }
  }

  Future<void> _fetchListingDetails() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('product_listings').doc(widget.listingId!).get();
      final listing = ProductListing.fromFirestore(doc);

      _productNameController.text = listing.productName;
      _emojiController.text = listing.emoji;
      _quantityValueController.text = listing.quantityValue.toString();
      _pricePerUnitController.text = listing.pricePerUnit.toString();
      _descriptionController.text = listing.description;
      _farmerNameController.text = listing.farmerName;
      _phoneNumberController.text = listing.farmerPhoneNumber;
      _addressController.text = listing.farmerAddress;
      _stateController.text = listing.farmerState;
      _districtController.text = listing.farmerDistrict;
      _pincodeController.text = listing.farmerPincode;
      
      setState(() {
        _productType = listing.productType;
        _isOrganic = listing.isOrganic;
        _quantityUnit = listing.quantityUnit;
        _qualityGrade = listing.qualityGrade;
        _existingImageUrls = List<String>.from(listing.productImageUrls);
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load listing: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _farmerNameController.text = data['name'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? user.phoneNumber ?? '';
          _addressController.text = data['address'] ?? '';
          _stateController.text = data['state'] ?? '';
          _districtController.text = data['district'] ?? '';
          _pincodeController.text = data['pincode'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    for (var file in pickedFiles) {
      _selectedImages.add(await file.readAsBytes());
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in.')));
        setState(() => _isLoading = false);
        return;
      }

      final String uuid = _isEditMode ? (await FirebaseFirestore.instance.collection('product_listings').doc(widget.listingId!).get()).data()!['uuid'] : _generateProductId(_productNameController.text);

      final listingData = ProductListing(
        id: _isEditMode ? widget.listingId! : null,
        uuid: uuid,
        farmerUID: user.uid,
        productName: _productNameController.text,
        productType: _productType,
        isOrganic: _isOrganic,
        emoji: _emojiController.text,
        quantityValue: double.tryParse(_quantityValueController.text) ?? 0,
        quantityUnit: _quantityUnit,
        qualityGrade: _qualityGrade,
        pricePerUnit: double.tryParse(_pricePerUnitController.text) ?? 0,
        description: _descriptionController.text,
        productImageUrls: _existingImageUrls,
        farmerName: _farmerNameController.text,
        farmerPhoneNumber: _phoneNumberController.text,
        farmerAddress: _addressController.text,
        farmerState: _stateController.text,
        farmerDistrict: _districtController.text,
        farmerPincode: _pincodeController.text,
      );

      try {
        if (_isEditMode) {
          await _listingService.updateProductListing(listingData, _selectedImages);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing updated successfully!')));
        } else {
          await _listingService.createProductListing(listingData, _selectedImages);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing created successfully!')));
        }
        if(mounted) context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save listing: $e')));
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Listing' : 'Create Listing'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isEditMode ? 'Edit Product Listing' : 'Create Product Listing', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 700) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildProductInfoColumn()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildFarmerInfoColumn()),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildProductInfoColumn(),
                            const SizedBox(height: 24),
                            _buildFarmerInfoColumn(),
                          ],
                        );
                      }
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(_isEditMode ? 'Update Listing' : 'Create Listing', style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductInfoColumn() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            TextFormField(controller: _productNameController, decoration: const InputDecoration(labelText: 'Product Name *'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _emojiController, decoration: const InputDecoration(labelText: 'Product Emoji (e.g., 🍎)')),
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
              contentPadding: EdgeInsets.zero,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: TextFormField(controller: _quantityValueController, decoration: const InputDecoration(labelText: 'Quantity *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _quantityUnit,
                  items: ['kg', 'quintal'].map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                  onChanged: (value) => setState(() => _quantityUnit = value!),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _qualityGrade,
              decoration: const InputDecoration(labelText: 'Quality Grade'),
              items: ['A', 'B', 'C'].map((grade) => DropdownMenuItem(value: grade, child: Text(grade))).toList(),
              onChanged: (value) => setState(() => _qualityGrade = value!),
            ),
            TextFormField(controller: _pricePerUnitController, decoration: const InputDecoration(labelText: 'Price per Unit (₹) *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 16),
            _buildImagePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerInfoColumn() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Farmer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            TextFormField(controller: _farmerNameController, decoration: const InputDecoration(labelText: 'Full Name *'), readOnly: true),
            TextFormField(controller: _phoneNumberController, decoration: const InputDecoration(labelText: 'Phone Number')),
            TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Farm Address'), maxLines: 2),
            TextFormField(controller: _stateController, decoration: const InputDecoration(labelText: 'State')),
            TextFormField(controller: _districtController, decoration: const InputDecoration(labelText: 'District')),
            TextFormField(controller: _pincodeController, decoration: const InputDecoration(labelText: 'Pincode'), keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _existingImageUrls.isEmpty && _selectedImages.isEmpty
              ? Center(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add Images'),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageUrls.length + _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _existingImageUrls.length + _selectedImages.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.green),
                          onPressed: _pickImages,
                          tooltip: 'Add more images',
                        ),
                      );
                    }

                    Widget imageWidget;
                    if (index < _existingImageUrls.length) {
                      imageWidget = Image.network(_existingImageUrls[index], fit: BoxFit.cover);
                    } else {
                      final imageBytes = _selectedImages[index - _existingImageUrls.length];
                      imageWidget = Image.memory(imageBytes, fit: BoxFit.cover);
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 100, height: 100, child: imageWidget)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
