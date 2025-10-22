import 'package:farm_connect/src/services/feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PurchaseSuccessPage extends StatefulWidget {
  const PurchaseSuccessPage({Key? key}) : super(key: key);

  @override
  _PurchaseSuccessPageState createState() => _PurchaseSuccessPageState();
}

class _PurchaseSuccessPageState extends State<PurchaseSuccessPage> {
  final _feedbackController = TextEditingController();
  final _feedbackService = FeedbackService();

  void _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback before submitting.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await _feedbackService.submitFeedback(_feedbackController.text);
      _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              const Text('Purchase Successful!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Thank you for your order. Your items will be processed shortly.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 48),
              _buildFeedbackForm(context),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20), // Dark Green
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => context.go('/buyer-dashboard'),
                  child: const Text('CONTINUE SHOPPING', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackForm(BuildContext context) {
    return Column(
      children: [
        const Text('Leave us some feedback!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _feedbackController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tell us about your experience...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _submitFeedback,
          child: const Text('Submit Feedback'),
        ),
      ],
    );
  }
}