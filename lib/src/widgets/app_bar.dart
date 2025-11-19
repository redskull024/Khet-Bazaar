import 'package:farm_connect/src/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isBuyer;
  const CustomAppBar({super.key, this.isBuyer = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          color: AppColors.lightGreenNavBar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('KhetBazaar', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 24, fontWeight: FontWeight.bold)),
              if (isBuyer) ...[
                if (!isMobile)
                  Row(
                    children: [
                      _AppBarLink(text: 'Home', onTap: () => context.go('/buyer-dashboard')),
                      _AppBarLink(text: 'Orders', onTap: () => context.go('/my-orders')),
                      _AppBarLink(text: 'About Us', onTap: () => context.go('/about-us', extra: true)),
                      IconButton(icon: const FaIcon(FontAwesomeIcons.cartShopping), color: AppColors.primaryDarkGreen, onPressed: () => context.go('/cart')),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        color: AppColors.primaryDarkGreen,
                        tooltip: 'Logout',
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          context.go('/language-selection');
                        },
                      ),
                    ],
                  )
                else
                  PopupMenuButton(
                    icon: const Icon(Icons.menu, color: AppColors.primaryDarkGreen),
                    itemBuilder: (context) => [
                      PopupMenuItem(child: const Text('Home'), onTap: () => context.go('/buyer-dashboard')),
                      PopupMenuItem(child: const Text('Orders'), onTap: () => context.go('/my-orders')),
                      PopupMenuItem(child: const Text('About Us'), onTap: () => context.go('/about-us', extra: true)),
                      PopupMenuItem(child: const Text('Cart'), onTap: () => context.go('/cart')),
                      PopupMenuItem(child: const Text('Logout'), onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        context.go('/language-selection');
                      }),
                    ],
                  ),
              ] else ...[
                PopupMenuButton(
                  icon: const Icon(Icons.menu, color: AppColors.primaryDarkGreen),
                  itemBuilder: (context) => [
                    PopupMenuItem(child: const Text('About Us'), onTap: () => context.go('/about-us')),
                    PopupMenuItem(child: const Text('Login'), onTap: () => context.go('/login')),
                  ],
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}

class _AppBarLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _AppBarLink({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap ?? () {},
      child: Text(text, style: const TextStyle(color: AppColors.primaryDarkGreen, fontSize: 16)),
    );
  }
}
