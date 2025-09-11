import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myapp/scientific_keyboard.dart';
import 'package:myapp/converter_screen.dart';
import 'dart:math';

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
  Color _accentColor = Colors.deepOrange;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        title: 'Neumorphic Calculator',
        theme: _buildTheme(Brightness.light, themeProvider.accentColor),
        darkTheme: _buildTheme(Brightness.dark, themeProvider.accentColor),
        themeMode: themeProvider.themeMode,
        home: const CalculatorScreen(),
      );
    });
  }

  ThemeData _buildTheme(Brightness brightness, Color accentColor) {
    final bool isLight = brightness == Brightness.light;
    final Color backgroundColor = isLight ? const Color(0xFFE0E5EC) : const Color(0xFF2E3239);
    final Color textColor = isLight ? Colors.black87 : Colors.white70;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).copyWith(
        displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: textColor),
        headlineSmall: TextStyle(fontSize: 24, color: textColor.withOpacity(0.7)),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: brightness,
        primary: accentColor,
        secondary: isLight ? Colors.red : Colors.redAccent,
        tertiary: isLight ? Colors.blue : Colors.lightBlueAccent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
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
      } else if (['sin', 'cos', 'tan', 'log', '√', 'x²'].contains(buttonText)) {
        _handleScientificFunction(buttonText);
      } else if (buttonText == 'π') {
        _expression += pi.toString();
      } else if (buttonText == 'e') {
        _expression += e.toString();
      } else {
        _expression += buttonText;
      }
    });
  }

  void _handleScientificFunction(String function) {
    try {
      final number = double.parse(_expression);
      double result;
      switch (function) {
        case 'sin':
          result = sin(number);
          break;
        case 'cos':
          result = cos(number);
          break;
        case 'tan':
          result = tan(number);
          break;
        case 'log':
          result = log(number);
          break;
        case '√':
          result = sqrt(number);
          break;
        case 'x²':
          result = pow(number, 2).toDouble();
          break;
        default:
          result = 0;
      }
      _result = result.toString();
      _history.add('$function($_expression) = $_result');
    } catch (e) {
      _result = 'Error';
    }
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
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              setState(() {
                _history.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showThemeDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Column(
              children: [
                _buildDisplay(),
                _buildHistory(),
                if (orientation == Orientation.portrait)
                  _buildKeyboard()
                else
                  Expanded(
                    flex: 4,
                    child: ScientificCalculatorKeyboard(onButtonPressed: _onButtonPressed),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ConverterScreen()));
        },
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('System'),
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Light'),
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Dark'),
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),
              const Text('Accent Color'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorOption(context, Colors.deepOrange),
                  _buildColorOption(context, Colors.blue),
                  _buildColorOption(context, Colors.green),
                  _buildColorOption(context, Colors.red),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(BuildContext context, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        themeProvider.setAccentColor(color);
        Navigator.of(context).pop();
      },
      child: CircleAvatar(backgroundColor: color),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_result.isNotEmpty && _result != 'Error')
                  IconButton(
                    icon: Icon(Icons.share, color: Theme.of(context).colorScheme.tertiary),
                    onPressed: () {
                      Share.share('Calculator Result: $_result');
                    },
                  ),
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: _result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result copied to clipboard')),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        _result.isEmpty ? '0' : _result,
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
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
          final historyEntry = _history[_history.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ActionChip(
              label: Text(historyEntry),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              onPressed: () {
                setState(() {
                  _expression = historyEntry.split(' = ')[0];
                  _result = historyEntry.split(' = ')[1];
                });
              },
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
    final Color shadowColor = isLight ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.5);
    final Color highlightColor = isLight ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1);

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
