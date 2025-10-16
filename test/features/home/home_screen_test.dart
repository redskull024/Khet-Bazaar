
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm_connect/main.dart';

void main() {
  testWidgets('HomeScreen has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('FarmConnect'), findsOneWidget);
    expect(find.text('Welcome to FarmConnect!'), findsOneWidget);
  });
}
