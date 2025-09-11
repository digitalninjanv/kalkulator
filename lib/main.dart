import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const CalculatorApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final ThemeData lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF007AFF),
            secondary: Color(0xFFFF9500),
            error: Color(0xFFFF3B30),
            surface: Color(0xFFF2F2F7),
            onSurface: Colors.black,
          ),
          textTheme: GoogleFonts.robotoTextTheme(
            const TextTheme(
              displayLarge: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              headlineSmall: TextStyle(fontSize: 32, color: Colors.grey),
            ),
          ),
          scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        );

        final ThemeData darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0A84FF),
            secondary: Color(0xFFFF9F0A),
            error: Color(0xFFFF453A),
            surface: Color(0xFF1C1C1E),
            onSurface: Colors.white,
          ),
          textTheme: GoogleFonts.robotoTextTheme(
            const TextTheme(
              displayLarge: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
              headlineSmall: TextStyle(fontSize: 32, color: Colors.grey),
            ),
          ),
          scaffoldBackgroundColor: Colors.black,
        );

        return MaterialApp(
          title: 'Modern Calculator',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const CalculatorScreen(),
        );
      },
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  final List<String> _history = [];
  bool _isResult = false;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (_isResult && !['+', '−', '×', '÷', '%'].contains(buttonText)) {
        _expression = '';
      }
      _isResult = false;

      switch (buttonText) {
        case 'AC':
          _expression = '';
          _result = '0';
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          break;
        case '=':
          try {
            final evaluatedResult = _evalExpression(_expression);
            if (_expression.isNotEmpty) {
              _history.add('$_expression = $evaluatedResult');
            }
            _result = evaluatedResult;
            _expression = _result;
            _isResult = true;
          } catch (e) {
            _result = 'Error';
          }
          break;
        default:
          _expression += buttonText;
      }
    });
  }

  String _evalExpression(String expression) {
    if (expression.isEmpty) return '0';
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');

    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      return eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
    } catch (e) {
      return "Error";
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDisplay(),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      flex: 3, // Gave display less space
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
            ),
            const SizedBox(height: 8),
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
    return Expanded(
      flex: 5, // Gave keyboard more space
      child: Container(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12, // Reduced spacing
            mainAxisSpacing: 12, // Reduced spacing
            childAspectRatio: 1.1, // Adjusted aspect ratio
          ),
          itemCount: _buttons.length,
          itemBuilder: (context, index) {
            final buttonText = _buttons[index];
            return CalculatorButton(
              text: buttonText,
              onPressed: () => _onButtonPressed(buttonText),
              color: _getButtonColor(buttonText),
              textColor: _getButtonTextColor(buttonText),
            );
          },
        ),
      ),
    );
  }

  Color _getButtonColor(String buttonText) {
    final colorScheme = Theme.of(context).colorScheme;
    if (buttonText == '=') {
      return colorScheme.primary;
    }
    return colorScheme.surface;
  }

  Color _getButtonTextColor(String buttonText) {
    final colorScheme = Theme.of(context).colorScheme;
     if (['AC', '⌫'].contains(buttonText)) {
      return colorScheme.error;
    }
    if (['+', '−', '×', '÷', '%'].contains(buttonText)) {
      return colorScheme.secondary;
    }
    if (buttonText == '=') {
      return Colors.white;
    }
    return colorScheme.onSurface;
  }

  final List<String> _buttons = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '00', '0', '.', '=',
  ];
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Center(
        child: AutoSizeText(
          text,
          style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500),
          maxLines: 1,
          minFontSize: 18,
        ),
      ),
    );
  }
}
