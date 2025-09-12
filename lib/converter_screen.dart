import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

// 1. Converter Logic Provider
class ConverterProvider with ChangeNotifier {
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meters';
  String _toUnit = 'Kilometers';
  String _inputValue = '';
  String _result = '';

  String get selectedCategory => _selectedCategory;
  String get fromUnit => _fromUnit;
  String get toUnit => _toUnit;
  String get inputValue => _inputValue;
  String get result => _result;

  final Map<String, List<String>> categories = {
    'Length': ['Meters', 'Kilometers', 'Centimeters', 'Inches', 'Feet'],
    'Weight': ['Grams', 'Kilograms', 'Pounds', 'Ounces'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
  };

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _fromUnit = categories[category]![0];
    _toUnit = categories[category]![1];
    _inputValue = '';
    _result = '';
    notifyListeners();
  }

  void setFromUnit(String unit) {
    if (_fromUnit == unit) return;
    _fromUnit = unit;
    _convert();
  }

  void setToUnit(String unit) {
    if (_toUnit == unit) return;
    _toUnit = unit;
    _convert();
  }

  void setInputValue(String value) {
    if (_inputValue == value) return;
    _inputValue = value;
    _convert();
  }

  void _convert() {
    if (_inputValue.isEmpty) {
      _result = '';
      notifyListeners();
      return;
    }

    double? input = double.tryParse(_inputValue);
    if (input == null) {
      _result = 'Invalid Input';
      notifyListeners();
      return;
    }

    double output = 0;

    if (_selectedCategory == 'Length') {
      double meters = _toMeters(input, _fromUnit);
      output = _fromMeters(meters, _toUnit);
    } else if (_selectedCategory == 'Weight') {
      double grams = _toGrams(input, _fromUnit);
      output = _fromGrams(grams, _toUnit);
    } else if (_selectedCategory == 'Temperature') {
      double celsius = _toCelsius(input, _fromUnit);
      output = _fromCelsius(celsius, _toUnit);
    }

    _result = output.toStringAsFixed(2);
    notifyListeners();
  }

  double _toMeters(double v, String u) => v * {'Meters': 1, 'Kilometers': 1000, 'Centimeters': 0.01, 'Inches': 0.0254, 'Feet': 0.3048}[u]!;
  double _fromMeters(double m, String u) => m / {'Meters': 1, 'Kilometers': 1000, 'Centimeters': 0.01, 'Inches': 0.0254, 'Feet': 0.3048}[u]!;
  double _toGrams(double v, String u) => v * {'Grams': 1, 'Kilograms': 1000, 'Pounds': 453.592, 'Ounces': 28.3495}[u]!;
  double _fromGrams(double g, String u) => g / {'Grams': 1, 'Kilograms': 1000, 'Pounds': 453.592, 'Ounces': 28.3495}[u]!;
  double _toCelsius(double v, String u) => {'Celsius': v, 'Fahrenheit': (v - 32) * 5/9, 'Kelvin': v - 273.15}[u]!;
  double _fromCelsius(double c, String u) => {'Celsius': c, 'Fahrenheit': (c * 9/5) + 32, 'Kelvin': c + 273.15}[u]!;
}

// 2. Converter Screen UI
class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('Calculator', style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6), fontSize: 16))),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(20)),
              child: Text('Converter', style: TextStyle(color: colorScheme.onPrimary, fontSize: 16)),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) => IconButton(
              icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [CategorySelector(), SizedBox(height: 20), ConversionCard(isFrom: true), SizedBox(height: 20), ConversionCard(isFrom: false)],
        ),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // This widget only needs to read the provider to fire events, so we can use context.read
    final provider = context.read<ConverterProvider>();
    // We use a Selector to only rebuild when the selectedCategory or the list of categories changes.
    return Selector<ConverterProvider, String>(
      selector: (_, p) => p.selectedCategory,
      builder: (context, selectedCategory, child) {
         return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
          child: DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) => provider.setCategory(newValue!),
            items: provider.categories.keys.map<DropdownMenuItem<String>>((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
            dropdownColor: colorScheme.surfaceVariant,
          ),
        );
      },
    );
  }
}

class ConversionCard extends StatefulWidget {
  final bool isFrom;
  const ConversionCard({super.key, required this.isFrom});

  @override
  State<ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends State<ConversionCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isFrom) {
      _controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    if (widget.isFrom) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<ConverterProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Selector<ConverterProvider, List<String>>(
              selector: (_, p) => [p.fromUnit, p.toUnit, p.selectedCategory], // Rebuild dropdown when units or category change
              builder: (context, units, child) {
                return DropdownButton<String>(
                  value: widget.isFrom ? units[0] : units[1],
                  onChanged: (String? newValue) {
                    if (newValue == null) return;
                    widget.isFrom ? provider.setFromUnit(newValue) : provider.setToUnit(newValue);
                  },
                  items: provider.categories[units[2]]!.map<DropdownMenuItem<String>>((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  dropdownColor: colorScheme.surfaceVariant,
                );
              }),
          const SizedBox(height: 10),
          if (widget.isFrom)
            Selector<ConverterProvider, String>(
              selector: (_, p) => p.inputValue,
              builder: (context, inputValue, child) {
                // Manually update controller only if text is different to prevent cursor jumping
                if (inputValue != _controller.text) {
                  _controller.text = inputValue;
                  _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
                }
                return TextField(
                  controller: _controller,
                  onChanged: provider.setInputValue,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                );
              },
            )
          else
            Selector<ConverterProvider, String>(
              selector: (_, p) => p.result,
              builder: (context, result, child) {
                return Text(
                  result.isEmpty ? '0' : result,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                );
              },
            ),
        ],
      ),
    );
  }
}
