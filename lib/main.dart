import 'package:farm_connect/src/features/dashboard/about_us_page.dart';
import 'package:farm_connect/src/models/product_listing_model.dart';
import 'package:farm_connect/src/screens/cart_page.dart';
import 'package:farm_connect/src/screens/my_orders_page.dart';
import 'package:farm_connect/src/screens/purchase_success_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'src/features/auth/auth_service.dart';
import 'src/features/auth/login_page.dart';
import 'src/features/language_selection/language_selection_screen.dart';
import 'package:farm_connect/src/features/role_selection/presentation/role_selection_screen.dart';
import 'package:farm_connect/src/features/dashboard/farmer_dashboard_home.dart';
import 'package:farm_connect/src/features/dashboard/buyer_dashboard_screen.dart';
import 'src/features/dashboard/create_listing_page.dart';
import 'src/features/buyer/presentation/screens/product_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Farm Connect',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF3A5A40),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      builder: (context, child) => SafeArea(child: child!),
    );
  }
}

// --- ROUTER CONFIGURATION ---
final _router = GoRouter(
  initialLocation: '/language-selection',
  routes: [
    GoRoute(
      path: '/language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/farmer-dashboard',
      builder: (context, state) => const FarmerHomePage(),
    ),
    GoRoute(
      path: '/buyer-dashboard',
      builder: (context, state) => const BuyerDashboardScreen(),
    ),
    GoRoute(
      path: '/about-us',
      builder: (context, state) {
        final isBuyer = state.extra as bool? ?? false;
        return AboutUsPage(isBuyer: isBuyer);
      },
    ),
    GoRoute(
      path: '/product-detail/:productId',
      builder: (context, state) {
        final productId = state.pathParameters['productId'];
        if (productId != null) {
          return ProductDetailPage(productId: productId);
        } else {
          // Redirect or show an error if the ID is missing
          return const BuyerDashboardScreen();
        }
      },
    ),
    GoRoute(
      path: '/create-listing',
      builder: (context, state) => const CreateListingPage(), // For creating new listings
    ),
    GoRoute(
      path: '/edit-listing/:listingId',
      builder: (context, state) {
        final listingId = state.pathParameters['listingId']!;
        return CreateListingPage(listingId: listingId); // For editing existing listings
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/my-orders',
      builder: (context, state) => const MyOrdersPage(),
    ),
    GoRoute(
      path: '/purchase-success',
      builder: (context, state) => const PurchaseSuccessPage(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    final auth = FirebaseAuth.instance;
    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService();

    final isLoggedIn = auth.currentUser != null;
    final onAuthFlow = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/role-selection' || 
                       state.matchedLocation == '/language-selection';

    if (!isLoggedIn) {
      return onAuthFlow ? null : '/language-selection';
    }

    final userPrefs = await authService.getUserPreferences(auth.currentUser!.uid);
    final role = userPrefs?['role'];

    if (isLoggedIn && onAuthFlow) {
      if (role == 'farmer') return '/farmer-dashboard';
      if (role == 'buyer') return '/buyer-dashboard';
    }

    return null;
  },
);