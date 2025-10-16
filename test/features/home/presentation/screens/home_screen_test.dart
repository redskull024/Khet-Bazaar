
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm_connect/src/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Home')), findsOneWidget);
    expect(find.text('Welcome to the Home Screen!'), findsOneWidget);
  });
}
