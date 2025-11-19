import 'package:farm_connect/src/models/delivery_info_model.dart';
import 'package:farm_connect/src/services/address_service.dart';
import 'package:flutter/material.dart';

class AddressSelectionPopup extends StatefulWidget {
  final Function(DeliveryInfo) onAddressSelected;

  const AddressSelectionPopup({Key? key, required this.onAddressSelected}) : super(key: key);

  @override
  _AddressSelectionPopupState createState() => _AddressSelectionPopupState();
}

class _AddressSelectionPopupState extends State<AddressSelectionPopup> {
  final AddressService _addressService = AddressService();
  DeliveryInfo? _selectedAddress;
  bool _isAddingNew = false;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  void _saveNewAddress() async {
    if (_formKey.currentState!.validate()) {
      final newAddress = DeliveryInfo(
        fullName: _nameCtrl.text,
        mobileNumber: _mobileCtrl.text,
        addressLine1: _address1Ctrl.text,
        city: _cityCtrl.text,
        state: _stateCtrl.text,
        pincode: _pincodeCtrl.text,
      );
      try {
        await _addressService.saveAddress(newAddress);
        setState(() {
          _isAddingNew = false;
          // Clear controllers after saving
          _nameCtrl.clear();
          _mobileCtrl.clear();
          _address1Ctrl.clear();
          _cityCtrl.clear();
          _stateCtrl.clear();
          _pincodeCtrl.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save address: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isAddingNew ? 'Add New Address' : 'Select Delivery Address'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isAddingNew ? _buildAddAddressForm() : _buildAddressList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        if (!_isAddingNew)
          ElevatedButton(
            onPressed: _selectedAddress == null
                ? null
                : () => widget.onAddressSelected(_selectedAddress!),
            child: const Text('Use This Address'),
          ),
      ],
    );
  }

  Widget _buildAddressList() {
    return StreamBuilder<List<DeliveryInfo>>(
      stream: _addressService.getAddressesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final addresses = snapshot.data!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (addresses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No saved addresses. Please add one.'),
              )
            else
              SizedBox(
                height: 300, // Constrain height for the list
                child: ListView(
                  shrinkWrap: true,
                  children: addresses.map((address) => RadioListTile<DeliveryInfo>(
                        title: Text(address.fullName),
                        subtitle: Text('${address.addressLine1}, ${address.city}'),
                        value: address,
                        groupValue: _selectedAddress,
                        onChanged: (value) => setState(() => _selectedAddress = value),
                      )).toList(),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
              onPressed: () => setState(() => _isAddingNew = true),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddAddressForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile Number'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _address1Ctrl, decoration: const InputDecoration(labelText: 'Address'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _stateCtrl, decoration: const InputDecoration(labelText: 'State'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _pincodeCtrl, decoration: const InputDecoration(labelText: 'Pincode'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => setState(() => _isAddingNew = false), child: const Text('Back')),
                ElevatedButton(onPressed: _saveNewAddress, child: const Text('Save Address')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
