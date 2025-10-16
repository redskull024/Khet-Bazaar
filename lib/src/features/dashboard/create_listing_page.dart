
import 'dart:io';
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
  ProductListing? _existingListing;

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

  // State variables
  String? _quantityUnit = 'kg';
  String? _qualityGrade = 'Premium';
  final List<File> _selectedImages = [];
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
      _existingListing = listing;

      _productNameController.text = listing.productName;
      _quantityValueController.text = listing.quantityValue.toString();
      _pricePerUnitController.text = listing.pricePerUnit.toString();
      _descriptionController.text = listing.description;
      _farmerNameController.text = listing.farmerName;
      _phoneNumberController.text = listing.farmerPhoneNumber;
      _addressController.text = listing.farmerAddress;
      _stateController.text = listing.farmerState;
      _districtController.text = listing.farmerDistrict;
      _pincodeController.text = listing.farmerPincode;
      _quantityUnit = listing.quantityUnit;
      _qualityGrade = listing.qualityGrade;
      _existingImageUrls = List<String>.from(listing.productImageUrls);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load listing: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _farmerNameController.text = userDoc.data()?['name'] ?? '';
          _phoneNumberController.text = user.phoneNumber ?? '';
        });
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
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

      final listingData = ProductListing(
        id: _isEditMode ? widget.listingId! : '', // Use existing ID in edit mode
        farmerUID: user.uid,
        productName: _productNameController.text,
        quantityValue: double.tryParse(_quantityValueController.text) ?? 0,
        quantityUnit: _quantityUnit!,
        qualityGrade: _qualityGrade!,
        pricePerUnit: double.tryParse(_pricePerUnitController.text) ?? 0,
        description: _descriptionController.text,
        productImageUrls: _existingImageUrls, // Pass existing URLs
        farmerName: _farmerNameController.text,
        farmerPhoneNumber: _phoneNumberController.text,
        farmerAddress: _addressController.text,
        farmerState: _stateController.text,
        farmerDistrict: _districtController.text,
        farmerPincode: _pincodeController.text,
        status: _existingListing?.status ?? 'Active',
        inquiries: _existingListing?.inquiries ?? 0,
        createdAt: _existingListing?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      try {
        if (_isEditMode) {
          await _listingService.updateProductListing(widget.listingId!, listingData, _selectedImages);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing updated successfully!')));
        } else {
          await _listingService.createProductListing(listingData, _selectedImages);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing created successfully!')));
        }
        if(mounted) context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save listing: $e')));
      } finally {
        setState(() => _isLoading = false);
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProductInfoColumn()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildFarmerInfoColumn()),
                      ],
                    ),
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
      color: Colors.lightGreen[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(labelText: '🌾 Product Name *'),
              validator: (value) => value!.isEmpty ? 'Please enter a product name' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityValueController,
                    decoration: const InputDecoration(labelText: 'Quantity *'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _quantityUnit,
                  items: ['kg', 'quintal', 'ton'].map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                  onChanged: (value) => setState(() => _quantityUnit = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _qualityGrade,
              decoration: const InputDecoration(labelText: 'Quality Grade'),
              items: ['Premium', 'Grade A', 'Standard'].map((grade) => DropdownMenuItem(value: grade, child: Text(grade))).toList(),
              onChanged: (value) => setState(() => _qualityGrade = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pricePerUnitController,
              decoration: const InputDecoration(labelText: 'Price per Unit (₹) *'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter a price' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Product Images'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload New Images'),
            ),
            if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageUrls.length + _selectedImages.length,
                  itemBuilder: (context, index) {
                    if (index < _existingImageUrls.length) {
                      return Padding(padding: const EdgeInsets.all(8.0), child: Image.network(_existingImageUrls[index]));
                    }
                    final imageFile = _selectedImages[index - _existingImageUrls.length];
                    return Padding(padding: const EdgeInsets.all(8.0), child: Image.file(imageFile));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerInfoColumn() {
    return Card(
      color: Colors.lightGreen[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Farmer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _farmerNameController,
              decoration: const InputDecoration(labelText: 'Full Name *'),
              readOnly: true, // Auto-filled
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Farm Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(labelText: 'State'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'District'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pincodeController,
              decoration: const InputDecoration(labelText: 'Pincode'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
