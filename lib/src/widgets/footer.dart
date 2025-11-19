import 'package:farm_connect/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: AppColors.footerGreen,
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _FooterInfo()),
              Expanded(child: _FooterLinks(title: 'Navigation', links: {'Home': '/buyer-dashboard', 'Orders': '/my-orders', 'About Us': '/about-us'})),              
              Expanded(child: _FooterLinks(title: 'Socials', links: {'Facebook': '#', 'Twitter': '#', 'Instagram': '#'})), // Placeholder links
            ],
          );
        } else {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FooterInfo(),
              SizedBox(height: 30),
              _FooterLinks(title: 'Navigation', links: {'Home': '/buyer-dashboard', 'Orders': '/my-orders', 'About Us': '/about-us'}),
              SizedBox(height: 30),
              _FooterLinks(title: 'Socials', links: {'Facebook': '#', 'Twitter': '#', 'Instagram': '#'}), // Placeholder links
            ],
          );
        }
      }),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('KhetBazaar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Connecting farmers directly with buyers for fresh produce, fair prices, and sustainable farming.', style: TextStyle(color: Colors.white70, height: 1.5)),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final Map<String, String> links;
  const _FooterLinks({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...links.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: InkWell(
            onTap: () {
              if (entry.value != '#') {
                if (entry.key == 'About Us') {
                  context.go(entry.value, extra: true);
                } else {
                  context.go(entry.value);
                }
              }
            },
            child: Text(entry.key, style: const TextStyle(color: Colors.white70))
          )
        )),
      ],
    );
  }
}
