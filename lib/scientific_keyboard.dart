import 'package:flutter/material.dart';
import 'package:myapp/main.dart';

class ScientificCalculatorKeyboard extends StatelessWidget {
  final Function(String) onButtonPressed;

  const ScientificCalculatorKeyboard({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columns for scientific layout
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _scientificButtons.length,
      itemBuilder: (context, index) {
        final buttonText = _scientificButtons[index];
        return NeumorphicButton(
          text: buttonText,
          onPressed: () => onButtonPressed(buttonText),
          textColor: _getButtonTextColor(context, buttonText),
        );
      },
    );
  }

  Color _getButtonTextColor(BuildContext context, String buttonText) {
    if (['sin', 'cos', 'tan', 'log', '√', 'x²', 'π', 'e'].contains(buttonText)) {
      return Theme.of(context).colorScheme.primary;
    }
    if (['AC', '⌫'].contains(buttonText)) {
      return Theme.of(context).colorScheme.secondary;
    }
    if (buttonText == '=') {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white70);
  }

  final List<String> _scientificButtons = [
    'sin', 'cos', 'tan', 'log', 'AC',
    '√',   'x²',  '(',   ')', '⌫',
    '7',   '8',   '9',   '÷', '%',
    '4',   '5',   '6',   '×', '-',
    '1',   '2',   '3',   '+', '+/-',
    '0',   '.',   'π',   'e', '=',
  ];
}
