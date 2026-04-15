import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _TempUnit { celsius, fahrenheit, kelvin }

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  final _controller = TextEditingController();
  _TempUnit _from = _TempUnit.celsius;
  static const _labels = {
    _TempUnit.celsius: 'Celsius (°C)',
    _TempUnit.fahrenheit: 'Fahrenheit (°F)',
    _TempUnit.kelvin: 'Kelvin (K)',
  };

  double? _valueC;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    final raw = _controller.text.replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v == null) {
      setState(() => _valueC = null);
      return;
    }
    double c;
    switch (_from) {
      case _TempUnit.celsius:
        c = v;
      case _TempUnit.fahrenheit:
        c = (v - 32) * 5 / 9;
      case _TempUnit.kelvin:
        c = v - 273.15;
    }
    setState(() => _valueC = c);
  }

  String _fmt(double x) => x.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _valueC;
    final f = c != null ? (c * 9 / 5) + 32 : null;
    final k = c != null ? c + 273.15 : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Temperature conversion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownMenu<_TempUnit>(
              key: ValueKey(_from),
              initialSelection: _from,
              label: const Text('Convert from'),
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: _TempUnit.values
                  .map(
                    (u) => DropdownMenuEntry<_TempUnit>(
                      value: u,
                      label: _labels[u]!,
                    ),
                  )
                  .toList(),
              onSelected: (u) {
                if (u == null) return;
                setState(() {
                  _from = u;
                  _convert();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.,]*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _convert,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 24),
            if (c != null && f != null && k != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All units', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      _Row(label: _labels[_TempUnit.celsius]!, value: '${_fmt(c)} °C'),
                      _Row(label: _labels[_TempUnit.fahrenheit]!, value: '${_fmt(f)} °F'),
                      _Row(label: _labels[_TempUnit.kelvin]!, value: '${_fmt(k)} K'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
