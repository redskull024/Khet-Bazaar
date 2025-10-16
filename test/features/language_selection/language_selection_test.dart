import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm_connect/src/features/language_selection/presentation/language_selection_content.dart';

void main() {
  testWidgets('LanguageSelectionContent has a title and motto', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LanguageSelectionContent())));
    expect(find.text('Direct Farm Marketplace'), findsOneWidget);
    expect(find.text('Connect farmers directly with buyers. Fresh produce, fair prices, sustainable farming.'), findsOneWidget);
  });

  testWidgets('LanguageSelectionContent has a language prompt', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LanguageSelectionContent())));
    expect(find.text('Choose Your Language'), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
  });

  testWidgets('LanguageSelectionContent has 10 language buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LanguageSelectionContent())));
    expect(find.byType(Card), findsNWidgets(10));
  });

  testWidgets('Tapping on a language button navigates to the role selection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LanguageSelectionContent())));
    await tester.tap(find.byKey(const Key('language_button_en')));
    await tester.pumpAndSettle();
    expect(find.text('Role Selection Screen'), findsOneWidget);
  });
}