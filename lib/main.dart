import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';

import 'converter_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => ConverterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// 1. Theme Provider
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// 2. Calculator Logic Provider
class CalculatorProvider with ChangeNotifier {
  String _expression = '';
  String _result = '';

  String get expression => _expression;
  String get result => _result;

  void buttonPressed(String buttonText) {
    if (buttonText == 'AC') {
      _expression = '';
      _result = '';
    } else if (buttonText == '⌫') {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    } else if (buttonText == '=') {
      try {
        String finalExpression = _expression.replaceAll('×', '*').replaceAll('÷', '/');
        final parser = ShuntingYardParser();
        final expression = parser.parse(finalExpression);
        final evaluator = RealEvaluator();
        expression.accept(evaluator); // This populates the evaluator
        final double eval = evaluator.value; // The result is in the 'value' property

        _result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
      } catch (e) {
        _result = 'Error';
      }
    } else if (buttonText == '%') {
      if (_expression.isNotEmpty) {
        try {
          final parser = ShuntingYardParser();
          final expression = parser.parse(_expression);
          final evaluator = RealEvaluator();
          expression.accept(evaluator); // This populates the evaluator
          final double eval = evaluator.value; // The result is in the 'value' property

          _result = (eval / 100).toString();
          _expression = _result;
        } catch (e) {
          _result = 'Error';
        }
      }
    } else {
      _expression += buttonText;
    }
    notifyListeners();
  }
}


// 3. Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF008080); // Teal

    final TextTheme appTextTheme = TextTheme(
        displayLarge:
            GoogleFonts.roboto(fontSize: 57, fontWeight: FontWeight.bold),
        titleLarge:
            GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.roboto(fontSize: 16),
        headlineSmall:
            GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400));

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1c1c1c)),
      textTheme: appTextTheme,
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Calculator',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const CalculatorScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// 4. Calculator Screen UI
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: const Icon(Icons.menu),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Calculator',
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConverterScreen()),
                );
              },
              child: Text('Converter',
                  style: TextStyle(
                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()), // FIX: withOpacity deprecated
                      fontSize: 16)),
            ),
          ],
        ),
        actions: [
          // Use a Consumer just for the button to prevent the whole AppBar from rebuilding
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) => IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Display rebuilds based on CalculatorProvider changes
            Expanded(
              flex: 3,
              child: DisplayArea(),
            ),
            // ButtonPad is constant and does not need to rebuild
            Expanded(
              flex: 5,
              child: ButtonPad(),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for the display area, rebuilds when expression/result changes.
class DisplayArea extends StatelessWidget {
  const DisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Use a Consumer to only rebuild the text widgets
    return Consumer<CalculatorProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AutoSizeText(
                provider.expression.isEmpty ? '0' : provider.expression,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 32,
                    color: colorScheme.onSurface.withAlpha((0.6 * 255).round())), // FIX: withOpacity deprecated
              ),
              const SizedBox(height: 10),
              AutoSizeText(
                provider.result,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget for the button pad, which is constant.
class ButtonPad extends StatelessWidget {
  const ButtonPad({super.key});

  @override
  Widget build(BuildContext context) {
    final List<List<String>> buttonMap = [
      ['AC', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['+/-', '0', '.', '=']
    ];

    return Column(
      children: buttonMap.map((row) {
        return Expanded(
          child: Row(
            children: row.map((text) {
              return Expanded(
                // Use context.read inside onPressed so the button itself doesn't listen for changes
                child: CalculatorButton(
                  text: text,
                  onPressed: () =>
                      context.read<CalculatorProvider>().buttonPressed(text),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// Calculator Button Widget
class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CalculatorButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isOperator = ['÷', '×', '-', '+'].contains(text);
    final bool isEqual = text == '=';
    final bool isTopRow = ['AC', '⌫', '%'].contains(text);

    Color buttonColor;
    Color textColor;
    BoxShape shape = BoxShape.circle;

    if (isEqual) {
      buttonColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      shape = BoxShape.rectangle;
    } else if (isOperator) {
      buttonColor = colorScheme.primary.withAlpha(200); // More precise opacity
      textColor = colorScheme.onPrimary;
    } else if (isTopRow) {
      buttonColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
    } else {
      buttonColor = colorScheme.surfaceContainerHighest.withAlpha(80); // More precise opacity
      textColor = colorScheme.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            shape: shape,
            borderRadius:
                shape == BoxShape.rectangle ? BorderRadius.circular(24) : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
