
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/services/listing_service.dart';

class EditListingPopup extends StatefulWidget {
  final ProductListing listing;

  const EditListingPopup({Key? key, required this.listing}) : super(key: key);

  @override
  _EditListingPopupState createState() => _EditListingPopupState();
}

class _EditListingPopupState extends State<EditListingPopup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Controllers
  late TextEditingController _productNameCtrl;
  late TextEditingController _quantityValueCtrl;
  late TextEditingController _pricePerUnitCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _farmerNameCtrl;
  late TextEditingController _farmerPhoneCtrl;
  late TextEditingController _farmerAddressCtrl;
  late TextEditingController _farmerStateCtrl;
  late TextEditingController _farmerDistrictCtrl;
  late TextEditingController _farmerPincodeCtrl;
  late TextEditingController _emojiCtrl;

  // Form State
  late String _productType;
  late String _quantityUnit;
  late String _qualityGrade;
  late bool _isOrganic;
  final List<Uint8List> _newProductImages = [];
  late List<String> _existingImageUrls;

  @override
  void initState() {
    super.initState();
    // Pre-fill all controllers and state from the listing object
    final listing = widget.listing;
    _productNameCtrl = TextEditingController(text: listing.productName);
    _quantityValueCtrl = TextEditingController(text: listing.quantityValue.toString());
    _pricePerUnitCtrl = TextEditingController(text: listing.pricePerUnit.toString());
    _descriptionCtrl = TextEditingController(text: listing.description);
    _farmerNameCtrl = TextEditingController(text: listing.farmerName);
    _farmerPhoneCtrl = TextEditingController(text: listing.farmerPhoneNumber);
    _farmerAddressCtrl = TextEditingController(text: listing.farmerAddress);
    _farmerStateCtrl = TextEditingController(text: listing.farmerState);
    _farmerDistrictCtrl = TextEditingController(text: listing.farmerDistrict);
    _farmerPincodeCtrl = TextEditingController(text: listing.farmerPincode);
    _emojiCtrl = TextEditingController(text: listing.emoji);

    _productType = listing.productType;
    _quantityUnit = listing.quantityUnit;
    _qualityGrade = listing.qualityGrade;
    _isOrganic = listing.isOrganic;
    _existingImageUrls = List<String>.from(listing.productImageUrls);
  }

  @override
  void dispose() {
    // Dispose all controllers
    _productNameCtrl.dispose();
    _quantityValueCtrl.dispose();
    _pricePerUnitCtrl.dispose();
    _descriptionCtrl.dispose();
    _farmerNameCtrl.dispose();
    _farmerPhoneCtrl.dispose();
    _farmerAddressCtrl.dispose();
    _farmerStateCtrl.dispose();
    _farmerDistrictCtrl.dispose();
    _farmerPincodeCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    for (var file in pickedFiles) {
      _newProductImages.add(await file.readAsBytes());
    }
    setState(() {});
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newQuantity = double.tryParse(_quantityValueCtrl.text) ?? 0;
      final newStatus = newQuantity <= 0 ? 'Sold Out' : widget.listing.status;

      final updatedListing = ProductListing(
        id: widget.listing.id, // Keep the original ID
        uuid: widget.listing.uuid, // Keep the original UUID
        farmerUID: widget.listing.farmerUID, // Keep the original farmer UID
        createdAt: widget.listing.createdAt, // Preserve the original creation timestamp
        status: newStatus, // Set the new status
        productName: _productNameCtrl.text,
        productType: _productType,
        isOrganic: _isOrganic,
        emoji: _emojiCtrl.text,
        quantityValue: newQuantity,
        quantityUnit: _quantityUnit,
        qualityGrade: _qualityGrade,
        pricePerUnit: double.parse(_pricePerUnitCtrl.text),
        description: _descriptionCtrl.text,
        productImageUrls: _existingImageUrls, // Pass existing URLs
        farmerName: _farmerNameCtrl.text,
        farmerPhoneNumber: _farmerPhoneCtrl.text,
        farmerAddress: _farmerAddressCtrl.text,
        farmerState: _farmerStateCtrl.text,
        farmerDistrict: _farmerDistrictCtrl.text,
        farmerPincode: _farmerPincodeCtrl.text,
      );

      await ListingService().updateProductListing(updatedListing, _newProductImages);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated successfully!'), backgroundColor: Colors.green),
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
      title: const Text('Edit Listing'),
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
        ElevatedButton(onPressed: _submitForm, child: const Text('Save Changes')),
      ],
    );
  }

  // Re-used UI from CreateListingPopup
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
        OutlinedButton.icon(icon: const Icon(Icons.image), label: const Text('Upload/Add Images'), onPressed: _pickImages),
        // Display existing and newly picked images
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._existingImageUrls.map((url) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Stack(children: [Image.network(url, width: 80, height: 80, fit: BoxFit.cover), IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _existingImageUrls.remove(url)))]),
              )),
              ..._newProductImages.map((imgBytes) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.memory(imgBytes, width: 80, height: 80, fit: BoxFit.cover),
              )),
            ],
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
