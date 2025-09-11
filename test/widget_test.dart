
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const CalculatorApp(),
      ),
    );

    // Initial state: result display should be '0'
    final resultFinder = find.byWidgetPredicate(
      (Widget widget) =>
          widget is AutoSizeText &&
          widget.style?.fontSize == 80 && // Only the result has this big font
          widget.data == '0',
    );
    expect(resultFinder, findsOneWidget);

    // Find the '1' button's text, which is an AutoSizeText widget
    // that is a descendant of a CalculatorButton.
    final oneButtonTextFinder = find.descendant(
      of: find.byType(CalculatorButton),
      matching: find.byWidgetPredicate(
        (widget) => widget is AutoSizeText && widget.data == '1'
      )
    );

    expect(oneButtonTextFinder, findsOneWidget);

    // Tap the button. Tapping the text inside should trigger the button's onPressed.
    await tester.tap(oneButtonTextFinder);
    await tester.pump();

    // After tapping '1', the expression display should be '1'
    final expressionFinder = find.byKey(const Key('expression'));
    expect(expressionFinder, findsOneWidget);
    final expressionWidget = tester.widget<AutoSizeText>(expressionFinder);
    expect(expressionWidget.data, '1');
  });
}
