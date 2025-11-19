
import 'package:farm_connect/src/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:farm_connect/src/widgets/footer.dart';

class AboutUsPage extends StatelessWidget {
  final bool isBuyer;
  final bool hasScaffold;
  const AboutUsPage({Key? key, this.isBuyer = false, this.hasScaffold = true}) : super(key: key);

  // Hero Banner Section
  static Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF38761D),
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: const Column(
        children: [
          Text(
            'Who we are',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Designers, thinkers & collaborators',
            style: TextStyle(
              color: Color.fromARGB(151, 220, 221, 211),
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Section Title Widget
  static Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1E463E),
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Desktop layout for the philosophy text
  static Widget _buildDesktopPhilosophy() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(_philosophyText, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[850]))),
        const SizedBox(width: 24),
        Expanded(child: Text(_philosophyText2, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[850]))),
      ],
    );
  }

  // Mobile layout for the philosophy text
  static Widget _buildMobilePhilosophy() {
    return Column(
      children: [
        Text(_philosophyText, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[850])),
        const SizedBox(height: 16),
        Text(_philosophyText2, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[850])),
      ],
    );
  }

  // Desktop layout for the team cards
  static Widget _buildDesktopTeamLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TeamMemberCard(
          name: 'Sudeep Bhat',
          role: 'App Developer / Data Science Student',
          description: 'Responsible for building the mobile application’s core functionality and interface. Handles frontend design and integrates Firebase for authentication, real-time data, and storage.',
          imageUrl: 'https://media.licdn.com/dms/image/v2/D5603AQEm6_pRIO60lw/profile-displayphoto-scale_400_400/B56ZkAG0pYG4Ag-/0/1756643413705?e=1764201600&v=beta&t=yWi6Jc8ATyTb9l-pghiEP8de-0vKpf7_VK7OoF9cW8Y',
          linkedinUrl: 'https://www.linkedin.com/in/bhat-sudeep/',
        )),
        const SizedBox(width: 20),
        Expanded(child: _TeamMemberCard(
          name: 'Charan Gowda HV',
          role: 'Backend Engineer / Data Science Student',
          description: 'Manages all server-side operations, including data storage, product listings, and order handling. Works on Firebase backend integration and ensures data security.',
          imageUrl: 'https://media.licdn.com/dms/image/v2/D5635AQF483b51xQQJQ/profile-framedphoto-shrink_400_400/B56ZgWQHaHHcB0-/0/1752719980517?e=1763204400&v=beta&t=WI6FLOSdKClCiJ35rLa7RnJlmLbn-5qGnltDtPOelC0',
          linkedinUrl: 'https://www.linkedin.com/in/charan-gowda-h-v-698a2a25b/',
        )),
        const SizedBox(width: 20),
        Expanded(child: _TeamMemberCard(
          name: 'Akhil Varma GRS',
          role: 'UI/UX Designer / Data Science Student',
          description: 'Designs the app’s layout, color scheme, and user experience for easy accessibility. Focuses on creating intuitive dashboards and visuals to improve user engagement.',
          imageUrl: 'https://media.licdn.com/dms/image/v2/D5635AQHxg9y_b4NHtg/profile-framedphoto-shrink_400_400/B56Zd3ZaWgHUAo-/0/1750054840097?e=1763204400&v=beta&t=esHnRavalkntc5me8toasBj7Luml4LLM8_TrRWC4x-g',
          linkedinUrl: 'https://www.linkedin.com/in/g-akhilv/',
        )),
      ],
    );
  }

  // Mobile layout for the team cards
  static Widget _buildMobileTeamLayout() {
    return Column(
      children: [
        _TeamMemberCard(
          name: 'Sudeep Bhat',          
          role: 'App Developer / Data Science Student',
          description: 'Responsible for building the mobile application’s core functionality and interface. Handles frontend design and integrates Firebase for authentication, real-time data, and storage.',
          imageUrl: 'https://media.licdn.com/dms/image/v2/D5603AQEm6_pRIO60lw/profile-displayphoto-scale_400_400/B56ZkAG0pYG4Ag-/0/1756643413705?e=1764201600&v=beta&t=yWi6Jc8ATyTb9l-pghiEP8de-0vKpf7_VK7OoF9cW8Y',
          linkedinUrl: 'https://www.linkedin.com/in/bhat-sudeep/',
        ),
        const SizedBox(height: 20),
        _TeamMemberCard(
          name: 'Charan Gowda HV',
          role: 'Backend Engineer / Data Science Student',
          description: 'Manages all server-side operations, including data storage, product listings, and order handling. Works on Firebase backend integration and ensures data security.',
          imageUrl:  'https://media.licdn.com/dms/image/v2/D5635AQF483b51xQQJQ/profile-framedphoto-shrink_400_400/B56ZgWQHaHHcB0-/0/1752719980517?e=1763204400&v=beta&t=WI6FLOSdKClCiJ35rLa7RnJlmLbn-5qGnltDtPOelC0',
          linkedinUrl: 'https://www.linkedin.com/in/charan-gowda-h-v-698a2a25b/',
        ),
        const SizedBox(height: 20),
        _TeamMemberCard(
          name: 'Akhil Varma GRS',
          role: 'UI/UX Designer / Data Science Student',
          description: 'Designs the app’s layout, color scheme, and user experience for easy accessibility. Focuses on creating intuitive dashboards and visuals to improve user engagement.',
          imageUrl: 'https://media.licdn.com/dms/image/v2/D5635AQHxg9y_b4NHtg/profile-framedphoto-shrink_400_400/B56Zd3ZaWgHUAo-/0/1750054840097?e=1763204400&v=beta&t=esHnRavalkntc5me8toasBj7Luml4LLM8_TrRWC4x-g',
          linkedinUrl: 'https://www.linkedin.com/in/g-akhilv/',
        ),
      ],
    );
  }

  // Placeholder text for philosophy
  static const String _philosophyText =
      'At Khet Bazaar, we believe technology should serve the hands that feed us. Our goal is to empower farmers by giving them direct access to markets, ensuring they receive fair prices without exploitation by middlemen. By building a transparent and easy-to-use digital platform, we aim to make agriculture more profitable, accessible, and sustainable for every farmer.';
  static const String _philosophyText2 =
      "We also believe in creating a strong connection between rural producers and urban consumers. Through our app, buyers can discover fresh, local produce straight from the source, while farmers gain visibility and recognition for their work. Khet Bazaar stands for fair trade, transparency, and trust, promoting a future where farmers grow with dignity and technology drives inclusive rural development.";
  @override
  Widget build(BuildContext context) {
    final pageContent = SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 800;
                return Column(
                  children: [
                    _buildSectionTitle('Our Philosophy'),
                    const SizedBox(height: 24),
                    isDesktop ? _buildDesktopPhilosophy() : _buildMobilePhilosophy(),
                    const SizedBox(height: 60),
                    _buildSectionTitle('Our Team'),
                    const SizedBox(height: 24),
                    isDesktop ? _buildDesktopTeamLayout() : _buildMobileTeamLayout(),
                  ],
                );
              },
            ),
          ),
          if (isBuyer) const Footer(),
        ],
      ),
    );

    if (!hasScaffold) {
      return pageContent;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(isBuyer: isBuyer),
      body: pageContent,
    );
  }
}



// A reusable card widget for team members
class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;
  final String imageUrl;
  final String linkedinUrl;

  const _TeamMemberCard({
    Key? key,
    required this.name,
    required this.role,
    required this.description,
    required this.imageUrl,
    required this.linkedinUrl,
  }) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFFFFFFF),
                  backgroundImage: NetworkImage(imageUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E463E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5, color: Colors.grey[850]),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.linkedin, color: Color(0xFF0A66C2)),
              onPressed: () => _launchUrl(linkedinUrl),
              tooltip: 'View LinkedIn Profile',
            ),
          ),
        ],
      ),
    );
  }
}
