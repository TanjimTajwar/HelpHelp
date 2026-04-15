import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _useMetric = true;
  String _result = '';

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculate() {
    final w = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final h = double.tryParse(_heightController.text.replaceAll(',', '.'));
    if (w == null || h == null || w <= 0 || h <= 0) {
      setState(() => _result = '');
      return;
    }
    final weightKg = _useMetric ? w : w * 0.45359237;
    final heightM = _useMetric ? h / 100 : h * 0.3048;
    if (heightM <= 0) {
      setState(() => _result = '');
      return;
    }
    final bmi = weightKg / (heightM * heightM);
    final category = _categoryForBmi(bmi);
    setState(() {
      _result =
          'BMI: ${bmi.toStringAsFixed(1)}\nCategory: $category';
    });
  }

  String _categoryForBmi(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('BMI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Metric'),
                  icon: Icon(Icons.straighten_rounded),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Imperial'),
                  icon: Icon(Icons.height_rounded),
                ),
              ],
              selected: {_useMetric},
              onSelectionChanged: (s) {
                setState(() {
                  _useMetric = s.first;
                  _result = '';
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: _useMetric ? 'Weight (kg)' : 'Weight (lb)',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: _useMetric ? 'Height (cm)' : 'Height (ft, e.g. 5.9)',
                helperText: _useMetric
                    ? 'Enter centimetres'
                    : 'Feet as decimal feet (5 ft 9 in → 5.75)',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _result,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
