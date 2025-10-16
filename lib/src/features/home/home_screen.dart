import 'package:flutter/material.dart';

/// A simple placeholder screen to show after language selection.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome! Language Saved.'),
      ),
    );
  }
}