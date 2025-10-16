import 'package:flutter/material.dart';

class UpdateRequirementsPage extends StatelessWidget {
  const UpdateRequirementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Requirements'),
      ),
      body: const Center(
        child: Text('Update Requirements Form'),
      ),
    );
  }
}