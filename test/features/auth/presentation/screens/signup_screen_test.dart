
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm_connect/src/features/auth/presentation/screens/signup_screen.dart';

void main() {
  testWidgets('SignUpScreen has a title and form fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Sign Up')), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
