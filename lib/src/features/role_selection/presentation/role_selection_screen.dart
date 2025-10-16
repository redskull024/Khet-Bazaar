import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Add to pubspec.yaml
import 'package:farm_connect/src/core/constants/app_constants.dart';
import 'package:farm_connect/src/features/auth/application/auth_service.dart';

/// A screen where users choose their primary role in the app (Farmer or Buyer).
///
/// This selection is temporarily saved and the user is navigated to the login page.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    void onRoleSelected(String role) {
      authService.saveTemporaryRole(role).then((_) {
        context.push('/login'); // Navigate to the new login route
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0), // Light cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select whether you are looking to sell your produce or buy fresh from the farm.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
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
                        'Sell produce directly',
                        'Access a wider market',
                        'Get fair prices',
                      ],
                      onPressed: () => onRoleSelected(kRoleFarmer),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _RoleCard(
                      role: kRoleBuyer,
                      title: 'Buyer',
                      icon: FontAwesomeIcons.shoppingCart,
                      imageUrl: 'https://static.wixstatic.com/media/9181a6_c4ed74fd7aa342b781c3231a24e5bed2~mv2.png/v1/fill/w_430,h_269,al_c,lg_1,q_85,enc_auto/9181a6_c4ed74fd7aa342b781c3231a24e5bed2~mv2.png',
                      benefits: const [
                        'Buy fresh from farms',
                        'Traceability of food',
                        'Support local farmers',
                      ],
                      onPressed: () => onRoleSelected(kRoleBuyer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'You can change your role later in the settings.',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable card widget to display a user role option.
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
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: const Color(0xFF3A6548), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Image.network(imageUrl, height: 150), // Placeholder image
            const SizedBox(height: 20),
            ...benefits.map((benefit) => _BenefitRow(text: benefit)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A6548), // Dark green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Continue as $title'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget for displaying a benefit with a checkmark icon.
class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }
}