import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_connect/src/features/role_selection/presentation/role_selection_screen.dart';
import 'package:farm_connect/src/services/language_service.dart';

// Main screen widget
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F5EE), // Light cream/off-white
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderSection(),
            SizedBox(height: 48),
            RoleIntroductionSection(),
            SizedBox(height: 48),
            HowItWorksSection(),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// Custom AppBar with logo and navigation links
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 40),
          const SizedBox(width: 8),
          const Text(
            'FarmConnect',
            style: TextStyle(
              color: Color(0xFF1E463E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        _AppBarLink(text: 'About', onTap: () {}),
        _AppBarLink(text: 'How It Works', onTap: () {}),
        _AppBarLink(text: 'Support', onTap: () {}),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AppBarLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF1E463E), fontSize: 16),
      ),
    );
  }
}

// Header section with responsive layout
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Wide screen layout
            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: LanguageSelectionContent()),
                SizedBox(width: 48),
                Expanded(flex: 2, child: OnboardingImage()),
              ],
            );
          } else {
            // Narrow screen layout
            return const Column(
              children: [
                LanguageSelectionContent(),
                SizedBox(height: 48),
                OnboardingImage(),
              ],
            );
          }
        },
      ),
    );
  }
}

// Left column content with language selection
class LanguageSelectionContent extends StatelessWidget {
  const LanguageSelectionContent({super.key});

  static const List<Map<String, String>> _languages = [
    {'primary': 'English', 'secondary': 'English', 'code': 'en'},
    {'primary': 'ಕನ್ನಡ', 'secondary': 'Kannada', 'code': 'kn'},
    {'primary': 'हिंदी', 'secondary': 'Hindi', 'code': 'hi'},
    {'primary': 'తెలుగు', 'secondary': 'Telugu', 'code': 'te'},
    {'primary': 'தமிழ்', 'secondary': 'Tamil', 'code': 'ta'},
    {'primary': 'मराठी', 'secondary': 'Marathi', 'code': 'mr'},
    {'primary': 'മലയാളം', 'secondary': 'Malayalam', 'code': 'ml'},
    {'primary': 'ਪੰਜਾਬੀ', 'secondary': 'Punjabi', 'code': 'pa'},
    {'primary': 'राजस्थानी', 'secondary': 'Rajasthani', 'code': 'raj'},
    {'primary': 'اردو', 'secondary': 'Urdu', 'code': 'ur'},
  ];

  void _selectLanguage(BuildContext context, String localeCode) async {
    await LanguageService().saveLanguageSelection(localeCode);
    GoRouter.of(context).go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF1E463E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Direct Farm Marketplace",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Connect farmers directly with buyers. Fresh produce, fair prices, sustainable farming.",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        const Text(
          "Choose Your Language",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: _languages.map((lang) {
            return LanguageCard(
              primaryName: lang['primary']!,
              secondaryName: lang['secondary']!,
              onTap: () => _selectLanguage(context, lang['code']!),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Right column image placeholder
class OnboardingImage extends StatelessWidget {
  const OnboardingImage({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a placeholder as the asset is not available
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          "Image Placeholder\n(assets/farmer_onboarding.png)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

// Language button card
class LanguageCard extends StatelessWidget {
  final String primaryName;
  final String secondaryName;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.primaryName,
    required this.secondaryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Text(
              primaryName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E463E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              secondaryName,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E463E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section for introducing Farmer and Buyer roles
class RoleIntroductionSection extends StatelessWidget {
  const RoleIntroductionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Row(
        children: const [
          Expanded(
            child: RoleCard(
              title: "For Farmers",
              description: "List your products, manage inventory, and connect with a wider market.",
              icon: FontAwesomeIcons.tractor,
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: RoleCard(
              title: "For Buyers",
              description: "Discover fresh, local produce directly from farmers near you.",
              icon: FontAwesomeIcons.shoppingBasket,
            ),
          ),
        ],
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1E463E), size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E463E),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF1E463E),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Section explaining how the platform works
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: [
          const Text(
            "How It Works",
            style: TextStyle(
              color: Color(0xFF1E463E),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              HowItWorksStep(
                icon: FontAwesomeIcons.globe,
                title: "Choose Language & Role",
                description: "Select your preferred language and whether you're a farmer or a buyer.",
              ),
              HowItWorksStep(
                icon: FontAwesomeIcons.users,
                title: "Create Profile",
                description: "Set up your profile to start listing products or making purchases.",
              ),
              HowItWorksStep(
                icon: FontAwesomeIcons.shoppingCart,
                title: "Start Trading",
                description: "Connect directly and trade fresh produce with fair and transparent pricing.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HowItWorksStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const HowItWorksStep({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            FaIcon(icon, color: const Color(0xFF1E463E), size: 40),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E463E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E463E),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}