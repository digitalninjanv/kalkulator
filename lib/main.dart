import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
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
        String finalExpression = _expression;
        finalExpression = finalExpression.replaceAll('×', '*');
        finalExpression = finalExpression.replaceAll('÷', '/');

        Parser p = Parser();
        Expression exp = p.parse(finalExpression);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);

        _result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
      } catch (e) {
        _result = 'Error';
      }
    } else if (buttonText == '%') {
        if (_expression.isNotEmpty) {
            try {
                Parser p = Parser();
                Expression exp = p.parse(_expression);
                ContextModel cm = ContextModel();
                double eval = exp.evaluate(EvaluationType.REAL, cm);
                _result = (eval / 100).toString();
                _expression = _result;
            } catch (e) {
                _result = 'Error';
            }
        }
    }
    else {
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
      displayLarge: GoogleFonts.roboto(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.roboto(fontSize: 16),
      headlineSmall: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400)
    );

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
        background: const Color(0xFF1c1c1c)
      ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final calculatorProvider = Provider.of<CalculatorProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
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
            Text('Converter', style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6), fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildDisplay(calculatorProvider, colorScheme),
            _buildButtonPad(calculatorProvider, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay(CalculatorProvider provider, ColorScheme colorScheme) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AutoSizeText(
              provider.expression.isEmpty ? '0' : provider.expression,
              maxLines: 2,
              style: TextStyle(fontSize: 32, color: colorScheme.onBackground.withOpacity(0.6)),
            ),
            const SizedBox(height: 10),
            AutoSizeText(
              provider.result.isEmpty ? '' : provider.result,
              maxLines: 1,
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonPad(CalculatorProvider provider, ColorScheme colorScheme) {
    final buttonMap = [
      ['AC', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['+/-', '0', '.', '=']
    ];

    return Expanded(
      flex: 3,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: buttonMap.length * buttonMap[0].length,
        itemBuilder: (context, index) {
          final int row = index ~/ 4;
          final int col = index % 4;
          final String text = buttonMap[row][col];
          return CalculatorButton(
            text: text,
            onPressed: () => provider.buttonPressed(text),
            colorScheme: colorScheme,
          );
        },
      ),
    );
  }
}


// 5. Calculator Button Widget
class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOperator = ['÷', '×', '-', '+', '='].contains(text);
    final bool isTopRow = ['AC', '⌫', '%'].contains(text);
    
    Color buttonColor;
    Color textColor;
    BoxShape shape = BoxShape.rectangle;
    
    if (isOperator) {
      buttonColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      shape = BoxShape.circle;
    } else if (isTopRow) {
      buttonColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
      shape = BoxShape.circle;
    } else {
       buttonColor = colorScheme.surfaceVariant.withOpacity(0.3);
       textColor = colorScheme.onSurfaceVariant;
       shape = BoxShape.circle;
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(100), // for ripple effect
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(24) : null,
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
    );
  }
}
