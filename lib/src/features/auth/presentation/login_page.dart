import 'package:flutter/material.dart';

/// A simple placeholder screen for the login page.
///
/// This screen is shown after the user selects their role.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Page. Role is saved temporarily.'),
      ),
    );
  }
}
