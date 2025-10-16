
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm_connect/src/features/auth/presentation/screens/role_selection_screen.dart';

void main() {
  testWidgets('RoleSelectionScreen has a title and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Select Your Role')), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Farmer'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Buyer'), findsOneWidget);
  });
}
