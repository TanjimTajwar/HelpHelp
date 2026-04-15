import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/islamic_inheritance_calculator.dart';

class IslamicInheritanceScreen extends StatefulWidget {
  const IslamicInheritanceScreen({super.key});

  @override
  State<IslamicInheritanceScreen> createState() =>
      _IslamicInheritanceScreenState();
}

class _IslamicInheritanceScreenState extends State<IslamicInheritanceScreen> {
  final _estateController = TextEditingController(text: '10000');
  final _sonsController = TextEditingController(text: '0');
  final _daughtersController = TextEditingController(text: '0');

  var _spouse = SpouseMode.none;
  var _wives = 1;
  var _father = false;
  var _mother = false;

  InheritanceOutcome? _outcome;

  @override
  void dispose() {
    _estateController.dispose();
    _sonsController.dispose();
    _daughtersController.dispose();
    super.dispose();
  }

  void _compute() {
    final estate =
        double.tryParse(_estateController.text.replaceAll(',', '.')) ?? 0;
    final sons = int.tryParse(_sonsController.text) ?? 0;
    final daughters = int.tryParse(_daughtersController.text) ?? 0;

    setState(() {
      _outcome = computeInheritance(
        estate: estate,
        sons: sons.clamp(0, 99),
        daughters: daughters.clamp(0, 99),
        fatherAlive: _father,
        motherAlive: _mother,
        spouseMode: _spouse,
        wifeCount: _wives,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Islamic inheritance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'This tool uses a simplified educational model (spouse shares, parents when there are children, sons/daughters, awl adjustments). It is not legal or religious advice; verify all distributions with qualified scholarship.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _estateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Estate value',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sonsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Sons',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _daughtersController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Daughters',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Spouse', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<SpouseMode>(
              segments: const [
                ButtonSegment(
                  value: SpouseMode.none,
                  label: Text('None'),
                ),
                ButtonSegment(
                  value: SpouseMode.husband,
                  label: Text('Husband'),
                ),
                ButtonSegment(
                  value: SpouseMode.wives,
                  label: Text('Wives'),
                ),
              ],
              selected: {_spouse},
              onSelectionChanged: (s) {
                setState(() => _spouse = s.first);
              },
            ),
            if (_spouse == SpouseMode.wives) ...[
              const SizedBox(height: 12),
              DropdownMenu<int>(
                key: ValueKey(_wives),
                initialSelection: _wives,
                label: const Text('Number of wives'),
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: List.generate(
                  4,
                  (i) => DropdownMenuEntry<int>(
                    value: i + 1,
                    label: '${i + 1}',
                  ),
                ),
                onSelected: (v) {
                  if (v == null) return;
                  setState(() => _wives = v);
                },
              ),
            ],
            const SizedBox(height: 16),
            Text('Parents (when there are children)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Father alive'),
              value: _father,
              onChanged: (v) => setState(() => _father = v),
            ),
            SwitchListTile(
              title: const Text('Mother alive'),
              value: _mother,
              onChanged: (v) => setState(() => _mother = v),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _compute,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 24),
            if (_outcome != null) _ResultPanel(outcome: _outcome!),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.outcome});

  final InheritanceOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final o = outcome;

    if (o.lines.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            o.warning ??
                'No distribution to show. Check amounts and family options.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breakdown', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...o.lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.label,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (line.detail != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              line.detail!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SelectableText(
                      line.amount.toStringAsFixed(2),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (o.unallocated > 0.001) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unallocated (other potential heirs / radd)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SelectableText(
                    o.unallocated.toStringAsFixed(2),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ],
            if (o.warning != null && o.warning!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                o.warning!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
