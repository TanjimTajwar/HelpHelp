import 'package:flutter/material.dart';

import 'bmi_screen.dart';
import 'islamic_inheritance_screen.dart';
import 'string_reversal_screen.dart';
import 'temperature_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = [
      _ToolCardData(
        title: 'String reversal',
        subtitle: 'Reverse any text instantly',
        icon: Icons.swap_horiz_rounded,
        builder: (_) => const StringReversalScreen(),
      ),
      _ToolCardData(
        title: 'BMI',
        subtitle: 'Body mass index from height & weight',
        icon: Icons.monitor_weight_outlined,
        builder: (_) => const BmiScreen(),
      ),
      _ToolCardData(
        title: 'Temperature',
        subtitle: 'Celsius, Fahrenheit, and Kelvin',
        icon: Icons.thermostat_auto_rounded,
        builder: (_) => const TemperatureScreen(),
      ),
      _ToolCardData(
        title: 'Islamic inheritance',
        subtitle: 'Faraid-style estimate (educational)',
        icon: Icons.balance_rounded,
        builder: (_) => const IslamicInheritanceScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanjida Go'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Tools',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a tool below. Islamic inheritance is a simplified educational aid — always confirm with qualified scholarship for real cases.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ...cards.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ToolCard(data: c),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCardData {
  const _ToolCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.data});

  final _ToolCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: data.builder),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Icon(data.icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
