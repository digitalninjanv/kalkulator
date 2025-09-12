import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. Provider for Converter Logic
class ConverterProvider with ChangeNotifier {
  String _inputValue = '0';
  String _outputValue = '0';
  String _fromUnit = 'Meters';
  String _toUnit = 'Kilometers';
  String _conversionType = 'Length';

  final Map<String, List<String>> unitTypes = {
    'Length': ['Meters', 'Kilometers', 'Miles', 'Feet'],
    'Weight': ['Grams', 'Kilograms', 'Pounds', 'Ounces'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
  };

  // Conversion factors (to a base unit, e.g., meters for length)
  final Map<String, double> _conversionFactors = {
    // Length (base: Meter)
    'Meters': 1.0,
    'Kilometers': 1000.0,
    'Miles': 1609.34,
    'Feet': 0.3048,

    // Weight (base: Gram)
    'Grams': 1.0,
    'Kilograms': 1000.0,
    'Pounds': 453.592,
    'Ounces': 28.3495,
  };

  String get inputValue => _inputValue;
  String get outputValue => _outputValue;
  String get fromUnit => _fromUnit;
  String get toUnit => _toUnit;
  String get conversionType => _conversionType;
  List<String> get currentUnits => unitTypes[_conversionType]!;

  void onUnitChanged(String? newUnit, {required bool isFromUnit}) {
    if (newUnit == null) return;
    if (isFromUnit) {
      _fromUnit = newUnit;
    } else {
      _toUnit = newUnit;
    }
    _convert();
    notifyListeners();
  }

  void onConversionTypeChanged(String? newType) {
    if (newType == null) return;
    _conversionType = newType;
    _fromUnit = unitTypes[newType]![0];
    _toUnit = unitTypes[newType]![1];
    _inputValue = '0';
    _outputValue = '0';
    notifyListeners();
  }

  void onInput(String value) {
    if (_inputValue == '0' && value != '.') {
      _inputValue = value;
    } else if (value == '⌫') {
      _inputValue = _inputValue.length > 1
          ? _inputValue.substring(0, _inputValue.length - 1)
          : '0';
    } else if (value == 'AC') {
      _inputValue = '0';
      _outputValue = '0';
    } else if (_inputValue.contains('.') && value == '.') {
      // Do nothing if trying to add a second decimal point
      return;
    } else {
      _inputValue += value;
    }
    _convert();
    notifyListeners();
  }

  void _convert() {
    final double? input = double.tryParse(_inputValue);
    if (input == null) {
      _outputValue = 'Error';
      return;
    }

    // Handle Temperature separately
    if (_conversionType == 'Temperature') {
      _outputValue = _convertTemperature(input, _fromUnit, _toUnit);
      return;
    }

    // Standard conversion
    final double baseValue = input * _conversionFactors[_fromUnit]!;
    final double convertedValue = baseValue / _conversionFactors[_toUnit]!;

    _outputValue = convertedValue.toStringAsFixed(4);
  }

  String _convertTemperature(double value, String from, String to) {
    double celsius;

    // First, convert input to Celsius
    switch (from) {
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default: // Celsius
        celsius = value;
    }

    double result;
    // Then, convert from Celsius to the target unit
    switch (to) {
      case 'Fahrenheit':
        result = celsius * 9 / 5 + 32;
        break;
      case 'Kelvin':
        result = celsius + 273.15;
        break;
      default: // Celsius
        result = celsius;
    }

    return result.toStringAsFixed(2);
  }
}

// 2. Converter Screen UI
class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text('Calculator',
                  style: TextStyle(
                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()), // FIX: withOpacity deprecated
                      fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Converter',
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          // Keep the same theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: const [
            Expanded(flex: 3, child: ConversionDisplay()),
            Expanded(flex: 4, child: ConverterNumpad()),
          ],
        ),
      ),
    );
  }
}

class ConversionDisplay extends StatelessWidget {
  const ConversionDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final converter = Provider.of<ConverterProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DropdownButton<String>(
          value: converter.conversionType,
          onChanged: (newType) =>
              converter.onConversionTypeChanged(newType),
          items: converter.unitTypes.keys
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: colorScheme.primary, fontSize: 20)),
            );
          }).toList(),
            dropdownColor: colorScheme.surfaceContainerHighest,
            underline: Container(
            height: 2,
            color: colorScheme.primary, 
          ),
        ),
        _buildUnitRow(context, isFromUnit: true),
        const Icon(Icons.swap_vert, size: 30, color: Colors.grey),
        _buildUnitRow(context, isFromUnit: false),
      ],
    );
  }

  Widget _buildUnitRow(BuildContext context, {required bool isFromUnit}) {
    final converter = Provider.of<ConverterProvider>(context, listen: false);
    final textStyle = TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.onSurface);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: isFromUnit ? converter.fromUnit : converter.toUnit,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          onChanged: (newUnit) =>
              converter.onUnitChanged(newUnit, isFromUnit: isFromUnit),
          items: converter.currentUnits
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
            );
          }).toList(),
        ),
        Text(
          isFromUnit ? converter.inputValue : converter.outputValue,
          style: textStyle,
        ),
      ],
    );
  }
}

class ConverterNumpad extends StatelessWidget {
  const ConverterNumpad({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonMap = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['AC', '0', '.'],
      ['⌫'] // Backspace on its own row
    ];

    final converter = Provider.of<ConverterProvider>(context, listen: false);

    return Column(
      children: buttonMap.map((row) {
        return Expanded(
          child: Row(
            children: row.map((text) {
              // Special case for the wider backspace button
              if (text == '⌫') {
                return Expanded(
                  flex: 2, // Take up 2/3 of the space
                  child: CalculatorButton(
                    text: text,
                    onPressed: () => converter.onInput(text),
                  ),
                );
              }
              return Expanded(
                child: CalculatorButton(
                  text: text,
                  onPressed: () => converter.onInput(text),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// Reusing the CalculatorButton from the main screen for consistency
class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CalculatorButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
