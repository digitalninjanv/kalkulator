// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart'; // Import provider

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We need to wrap CalculatorApp with the providers it expects,
    // just like in main.dart.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const CalculatorApp(),
      ),
    );

    // Verify that the main app widget renders without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CalculatorHomePage), findsOneWidget);

    // Verify that the initial result '0' is displayed.
    // There might be multiple '0's on the screen (e.g., the button and the display)
    // so we specify that we expect to find at least one.
    expect(find.text('0'), findsWidgets);
  });
}
