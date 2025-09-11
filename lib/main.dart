import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:math_expressions/math_expressions.dart';

// --- Main App Setup ---
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const CalculatorApp(),
    ),
  );
}

// --- Theme Management ---
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  static const Color tealColor = Color(0xFF199183);

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.montserrat(fontSize: 72, fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.montserrat(fontSize: 28, color: Colors.grey[600]),
      titleLarge: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.montserrat(fontSize: 20),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: tealColor,
      textTheme: textTheme.apply(bodyColor: Colors.black, displayColor: Colors.black),
      colorScheme: const ColorScheme.light(primary: tealColor, secondary: tealColor),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      primaryColor: tealColor,
      textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      colorScheme: const ColorScheme.dark(primary: tealColor, secondary: tealColor),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Calculator',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const CalculatorScreen(),
        );
      },
    );
  }
}

// --- Calculator Screen ---
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';

  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'AC':
          _expression = '';
          _result = '0';
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
            if (_expression.isEmpty) _result = '0';
          }
          break;
        case '+/-':
          if (_result != '0' && _result.isNotEmpty) {
            if (_result.startsWith('-')) {
              _result = _result.substring(1);
            } else {
              _result = '-$_result';
            }
            _expression = _result;
          }
          break;
        case '=':
          try {
            final evaluatedResult = _evalExpression(_expression);
            _result = evaluatedResult;
          } catch (e) {
            _result = 'Error';
          }
          break;
        default:
          if (_result == '0' && buttonText != '.') {
             _expression = buttonText;
             _result = buttonText;
          } else {
             _expression += buttonText;
          }
      }
    });
  }

  String _evalExpression(String expression) {
    if (expression.isEmpty) return '0';
    String finalExpression = expression.replaceAll('×', '*').replaceAll('÷', '/');

    try {
      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 4).replaceAll(RegExp(r'\.0000$'), '');
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildDisplay(),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, size: 30),
          _buildCalculatorConverterToggle(),
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.light ? Icons.brightness_3 : Icons.brightness_7, size: 30),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorConverterToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor == Colors.white ? Colors.grey[200] : Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: CalculatorApp.tealColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Calculator', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Converter', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AutoSizeText(
              _expression,
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 1, 
              minFontSize: 20,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            AutoSizeText(
              _result,
              style: Theme.of(context).textTheme.displayLarge,
              maxLines: 1,
              minFontSize: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final buttonLayout = [
      ['AC', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['+/-', '0', '.', '='],
    ];

    return Expanded(
      flex: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: buttonLayout.map((row) {
            return Expanded(
              child: Row(
                children: row.map((buttonText) {
                  return CalculatorButton(
                    text: buttonText,
                    onPressed: () => _onButtonPressed(buttonText),
                    style: _getButtonStyle(buttonText, context),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(String buttonText, BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = Colors.transparent;
    Color foregroundColor = isDarkMode ? Colors.white : Colors.black;

    if (isDarkMode) {
      // Dark Mode Colors
      if (['AC', '⌫', '%', '÷'].contains(buttonText)) {
        backgroundColor = Colors.grey[400]!;
        foregroundColor = Colors.black;
      } else if (['×', '-', '+', '='].contains(buttonText)) {
        backgroundColor = CalculatorApp.tealColor;
        foregroundColor = Colors.white;
      } else {
        backgroundColor = const Color(0xFF3B3B3B);
        foregroundColor = Colors.white;
      }
    } else {
      // Light Mode Colors
       if (['AC', '⌫', '%', '÷', '×', '-', '+', '='].contains(buttonText)) {
        foregroundColor = CalculatorApp.tealColor;
      }
    }

    return TextButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: const CircleBorder(),
      textStyle: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w600),
    );
  }
}

// --- Calculator Button Widget ---
class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle style;

  const CalculatorButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: TextButton(
          onPressed: onPressed,
          style: style,
          child: Center(
            child: text == '⌫' 
                ? const Icon(Icons.backspace_outlined, size: 28) 
                : Text(text),
          ),
        ),
      ),
    );
  }
}
