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
      backgroundColor: const Color(0xFFFDFCF8), // Light cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select whether you are a farmer or a buyer to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _RoleCard(role: kRoleFarmer)),
                          const SizedBox(width: 24),
                          Expanded(child: _RoleCard(role: kRoleBuyer)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _RoleCard(role: kRoleFarmer),
                          const SizedBox(height: 24),
                          _RoleCard(role: kRoleBuyer),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'You can change your role later in the settings.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;

  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    final isFarmer = role == kRoleFarmer;
    final authService = AuthService();

    final title = isFarmer ? 'Farmer' : 'Buyer';
    final icon = isFarmer ? FontAwesomeIcons.leaf : FontAwesomeIcons.shoppingCart;
    final imageUrl = isFarmer
        ? 'https://static.wixstatic.com/media/9181a6_b190393a6def4e56a2eade1db0c6b9d4~mv2.png/v1/fill/w_430,h_269,al_c,lg_1,q_85,enc_auto/9181a6_b190393a6def4e56a2eade1db0c6b9d4~mv2.png'
        : 'https://static.wixstatic.com/media/9181a6_c4ed74fd7aa342b781c3231a24e5bed2~mv2.png/v1/fill/w_430,h_269,al_c,lg_1,q_85,enc_auto/9181a6_c4ed74fd7aa342b781c3231a24e5bed2~mv2.png';
    final bulletPoints = isFarmer
        ? ['List your produce', 'Connect with buyers', 'Get market insights']
        : ['Find fresh produce', 'Connect with farmers', 'Secure transactions'];
    final buttonText = 'Continue as $title';

    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: const Color(0xFF3A5A40), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            ...bulletPoints.map((text) => _BulletPoint(text: text)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await authService.saveTemporaryRole(role);
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A5A40), // Dark green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.checkCircle, color: Color(0xFF588157), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
