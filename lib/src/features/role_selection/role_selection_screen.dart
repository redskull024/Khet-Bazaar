import 'package:farm_connect/src/constants/app_constants.dart';
import 'package:farm_connect/src/features/auth/auth_service.dart';
import 'package:farm_connect/src/features/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Add font_awesome_flutter to pubspec.yaml

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  void _selectRole(BuildContext context, String role) async {
    await AuthService().saveTemporaryRole(role);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose Your Role',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Select whether you want to sell products as a farmer or buy them as a customer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _RoleCard(
                      role: kRoleFarmer,
                      title: 'Farmer',
                      icon: FontAwesomeIcons.leaf,
                      imageUrl: 'https://static.wixstatic.com/media/9181a6_b190393a6def4e56a2eade1db0c6b9d4~mv2.png/v1/fill/w_430,h_269,al_c,lg_1,q_85,enc_auto/9181a6_b190393a6def4e56a2eade1db0c6b9d4~mv2.png',
                      benefits: const [
                        'List your products for sale',
                        'Connect with buyers directly',
                        'Manage your inventory',
                      ],
                      onPressed: () => _selectRole(context, kRoleFarmer),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _RoleCard(
                      role: kRoleBuyer,
                      title: 'Buyer',
                      icon: FontAwesomeIcons.shoppingCart,
                      imageUrl: 'https://static.wixstatic.com/media/9181a6_c4ed74fd7aa342b781c3231a24e5bed2~mv2.png/v1/fill/w_430,h_269,al_c,lg_1,q_85,enc_auto/9181a6_c4ed74fd7aa342b781c3231a24e5bed2~mv2.png',
                      benefits: const [
                        'Browse local produce',
                        'Contact farmers easily',
                        'Get fresh products',
                      ],
                      onPressed: () => _selectRole(context, kRoleBuyer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'You can change your role later from the settings menu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;
  final String title;
  final IconData icon;
  final String imageUrl;
  final List<String> benefits;
  final VoidCallback onPressed;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.icon,
    required this.imageUrl,
    required this.benefits,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Image.network(imageUrl, height: 120, fit: BoxFit.cover),
            const SizedBox(height: 16),
            ...benefits.map((benefit) => _BenefitItem(text: benefit)).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Continue as $title', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;
  const _BenefitItem({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
