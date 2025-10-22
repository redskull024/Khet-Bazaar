import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_connect/src/constants/app_constants.dart';
import 'package:farm_connect/src/features/auth/auth_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E463E)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E463E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select whether you want to sell your produce or buy fresh from the farm.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E463E),
                ),
              ),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 700) {
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: RoleCard(role: kRoleFarmer)),
                        SizedBox(width: 24),
                        Expanded(child: RoleCard(role: kRoleBuyer)),
                      ],
                    );
                  } else {
                    return const Column(
                      children: [
                        RoleCard(role: kRoleFarmer),
                        SizedBox(height: 24),
                        RoleCard(role: kRoleBuyer),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'You can change your role later from your profile settings.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String role;
  const RoleCard({super.key, required this.role});

  void _selectRole(BuildContext context, String selectedRole) async {
    await AuthService().saveTemporaryRole(selectedRole);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool isFarmer = role == kRoleFarmer;

    final String title = isFarmer ? 'Farmer' : 'Buyer';
    final IconData icon = isFarmer ? FontAwesomeIcons.leaf : FontAwesomeIcons.shoppingCart;
    final String imagePath = isFarmer ? 'assets/role_farmer.png' : 'assets/role_buyer.png';
    final List<String> bulletPoints = isFarmer
        ? [
            'Sell produce directly to consumers',
            'Manage your inventory and orders',
            'Get fair prices for your hard work'
          ]
        : [
            'Buy fresh produce from local farms',
            'Enjoy farm-to-table transparency',
            'Support sustainable agriculture'
          ];
    final String buttonText = isFarmer ? 'Continue as Farmer' : 'Continue as Buyer';

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, color: const Color(0xFF1E463E)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E463E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Placeholder for\n$imagePath',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...bulletPoints.map((point) => BulletPoint(text: point)),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E463E), // Dark green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _selectRole(context, role),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.check, color: Colors.green, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E463E)),
            ),
          ),
        ],
      ),
    );
  }
}