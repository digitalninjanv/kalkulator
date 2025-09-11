import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neumorphic Calculator',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const CalculatorScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color backgroundColor = isLight ? const Color(0xFFE0E5EC) : const Color(0xFF2E3239);
    final Color textColor = isLight ? Colors.black87 : Colors.white70;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).copyWith(
        displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: textColor),
        headlineSmall: TextStyle(fontSize: 24, color: textColor.withOpacity(0.7)),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: brightness,
        primary: isLight ? Colors.deepOrange : Colors.orangeAccent,
        secondary: isLight ? Colors.red : Colors.redAccent,
        tertiary: isLight ? Colors.blue : Colors.lightBlueAccent,
      ),
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
  String _result = '';
  final List<String> _history = [];

  void _onButtonPressed(String buttonText) {
    Haptics.vibrate(HapticsType.light);
    setState(() {
      if (buttonText == 'AC') {
        _expression = '';
        _result = '';
      } else if (buttonText == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (buttonText == '=') {
        try {
          final evaluatedResult = _evalExpression(_expression);
          if (_expression.isNotEmpty) {
             _history.add('$_expression = $evaluatedResult');
          }
          _result = evaluatedResult;
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += buttonText;
      }
    });
  }

  String _evalExpression(String expression) {
    if (expression.isEmpty) return '';
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
    
    try {
      List<double> numbers = expression.split(RegExp(r'[+\-*/]')).map(double.parse).toList();
      List<String> operators = expression.split(RegExp(r'[0-9.]')).where((s) => s.isNotEmpty).toList();

      for (int i = 0; i < operators.length; i++) {
        if (operators[i] == '*' || operators[i] == '/') {
          if (operators[i] == '*') {
            numbers[i] = numbers[i] * numbers[i + 1];
          } else {
            numbers[i] = numbers[i] / numbers[i + 1];
          }
          numbers.removeAt(i + 1);
          operators.removeAt(i);
          i--;
        }
      }

      double result = numbers[0];
      for (int i = 0; i < operators.length; i++) {
        if (operators[i] == '+') {
          result += numbers[i + 1];
        } else if (operators[i] == '-') {
          result -= numbers[i + 1];
        }
      }
      return result.toString();
    } catch(e) {
      return "Error";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildDisplay(),
            _buildHistory(),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
             SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _expression,
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                _result.isEmpty ? '0' : _result,
                style: Theme.of(context).textTheme.displayLarge,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemCount: _history.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text(_history[_history.length - 1 - index]),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeyboard() {
    return Expanded(
      flex: 4,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _buttons.length,
        itemBuilder: (context, index) {
          final buttonText = _buttons[index];
          return NeumorphicButton(
            text: buttonText,
            onPressed: () => _onButtonPressed(buttonText),
            textColor: _getButtonTextColor(buttonText),
          );
        },
      ),
    );
  }

  Color _getButtonTextColor(String buttonText) {
    if (['AC', '⌫'].contains(buttonText)) {
      return Theme.of(context).colorScheme.secondary;
    }
    if (['+', '-', '×', '÷', '%'].contains(buttonText)) {
      return Theme.of(context).colorScheme.primary;
    }
    if (buttonText == '=') {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white70);
  }

  final List<String> _buttons = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '+/-', '=',
  ];
}

class NeumorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;

  const NeumorphicButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.black,
  });

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color baseColor = Theme.of(context).scaffoldBackgroundColor;
    final Color? shadowColor = isLight ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.5);
    final Color? highlightColor = isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _isPressed
              ? [
                  // Inner shadow effect
                  BoxShadow(
                    color: highlightColor!,
                    offset: const Offset(4, 4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: shadowColor!,
                    offset: const Offset(-4, -4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  // Outer shadow
                  BoxShadow(
                    color: shadowColor!,
                    offset: const Offset(-5, -5),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: highlightColor!,
                    offset: const Offset(5, 5),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
