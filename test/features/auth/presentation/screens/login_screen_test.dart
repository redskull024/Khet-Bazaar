
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm_connect/src/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen has a title and form fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Login')), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
