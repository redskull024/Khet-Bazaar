import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_connect/src/models/sales_notification_model.dart';
import 'package:farm_connect/src/features/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({Key? key}) : super(key: key);

  @override
  _FarmerProfileScreenState createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmAddressController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _email;
  String _selectedLanguage = 'English';
  bool _receiveNotifications = true;

  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _farmAddressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(Map<String, dynamic> currentData) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('user_preferences').doc(_uid).set({
          ...currentData, // Preserve existing data
          'fullName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'farmAddress': _farmAddressController.text,
          'farmState': _stateController.text,
          'farmDistrict': _districtController.text,
          'farmPincode': _pincodeController.text,
          'selectedLanguage': _selectedLanguage,
          'receiveNotifications': _receiveNotifications,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('user_preferences').doc(_uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data.'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No profile data found.'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        _nameController.text = userData['fullName'] ?? '';
        _phoneController.text = userData['phoneNumber'] ?? '';
        _farmAddressController.text = userData['farmAddress'] ?? '';
        _stateController.text = userData['farmState'] ?? '';
        _districtController.text = userData['farmDistrict'] ?? '';
        _pincodeController.text = userData['farmPincode'] ?? '';
        _email = FirebaseAuth.instance.currentUser?.email;
        _selectedLanguage = userData['selectedLanguage'] ?? 'English';
        _receiveNotifications = userData['receiveNotifications'] ?? true;

        return LayoutBuilder(builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildAccountDetails()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFarmDetails()),
                      ],
                    )
                  else ...[
                    _buildAccountDetails(),
                    const SizedBox(height: 16),
                    _buildFarmDetails(),
                  ],
                  const SizedBox(height: 16),
                  _buildPreferences(userData),
                  const SizedBox(height: 24),
                  _buildRecentSales(),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildAccountDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account & Personal Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
            ),
            const SizedBox(height: 16),
            Text('Email: ${_email ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farm & Business Location', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _farmAddressController,
              decoration: const InputDecoration(labelText: 'Farm Address'),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences(Map<String, dynamic> userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences & Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: ['English', 'Spanish', 'French', 'Hindi'].map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              decoration: const InputDecoration(labelText: 'Selected Language'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Receive Notifications'),
              value: _receiveNotifications,
              onChanged: (bool value) {
                setState(() {
                  _receiveNotifications = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: () => _saveProfile(userData), child: const Text('Save Changes')),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    await AuthService().signOut();
                    context.go('/login');
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Sales Notices', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sales_notifications')
              .where('farmerUID', isEqualTo: _uid)
              .orderBy('saleTimestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading sales notices.'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No recent sales.'));
            }

            final sales = snapshot.data!.docs.map((doc) => SalesNotificationModel.fromFirestore(doc)).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text('${sale.productName} SOLD OUT'),
                    subtitle: Text(
                        'to ${sale.buyerName} in ${sale.quantitySold} ${sale.unit} at ${sale.buyerLocation}'),
                    trailing: Text(TimeAgo.timeAgoSinceDate(sale.saleTimestamp.toDate())),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class TimeAgo {
  static String timeAgoSinceDate(DateTime date, {bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if (difference.inSeconds < 5) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
