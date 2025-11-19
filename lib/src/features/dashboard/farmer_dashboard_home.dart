import 'package:farm_connect/src/features/auth/auth_service.dart';
import 'package:farm_connect/src/features/dashboard/about_us_page.dart';
import 'package:flutter/material.dart';
import 'package:farm_connect/src/features/dashboard/farmer_analyze_screen.dart';
import 'package:farm_connect/src/features/dashboard/farmer_product_list_screen.dart';
import 'package:farm_connect/src/features/dashboard/widgets/create_listing_popup.dart';
import 'package:go_router/go_router.dart';

class FarmerHomePage extends StatefulWidget {
  const FarmerHomePage({super.key});

  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    FarmerAnalyzeScreen(),
    FarmerProductListScreen(),
    AboutUsPage(hasScaffold: false),
  ];

  static const List<String> _screenTitles = <String>[
    'Analyze',
    'My Products',
    'About Us',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    const farmerDashboardColor = Color.fromARGB(255, 215, 246, 224);

    final List<Widget> actions = [
      ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Create Listing'),
        onPressed: () => showDialog(context: context, builder: (_) => const CreateListingPopup()),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await authService.signOut();
          if (mounted) context.go('/');
        },
        tooltip: 'Logout',
      ),
      const SizedBox(width: 8),
    ];

    return Scaffold(
      backgroundColor: farmerDashboardColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // --- DESKTOP VIEW ---
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: const Color.fromARGB(255, 240, 247, 242),
                  indicatorColor: Colors.green[200],
                  selectedIconTheme: const IconThemeData(color: Colors.black),
                  unselectedIconTheme: const IconThemeData(color: Colors.black54),
                  selectedLabelTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Analyze'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list_alt_outlined),
                      selectedIcon: Icon(Icons.list_alt),
                      label: Text('My Products'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.info_outline),
                      selectedIcon: Icon(Icons.info),
                      label: Text('About Us'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Column(
                    children: [
                      AppBar(
                        title: Text(_screenTitles[_selectedIndex]),
                        actions: actions,
                        elevation: 1,
                        backgroundColor: farmerDashboardColor,
                        foregroundColor: Colors.black,
                        automaticallyImplyLeading: false,
                      ),
                      Expanded(
                        child: _screens[_selectedIndex],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // --- MOBILE VIEW ---
            return Scaffold(
              backgroundColor: farmerDashboardColor,
              appBar: AppBar(
                title: Text(_screenTitles[_selectedIndex]),
                actions: actions,
                backgroundColor: farmerDashboardColor,
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                      ),
                      child: const Text(
                        'Farm Connect',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.analytics, color: Colors.black87),
                      title: const Text('Analyze'),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        _onItemTapped(0);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.list_alt, color: Colors.black87),
                      title: const Text('My Products'),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        _onItemTapped(1);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info, color: Colors.black87),
                      title: const Text('About Us'),
                      selected: _selectedIndex == 2,
                      onTap: () {
                        _onItemTapped(2);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              body: _screens[_selectedIndex],
            );
          }
        },
      ),
    );
  }
}