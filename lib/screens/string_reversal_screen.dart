import 'package:flutter/material.dart';

class StringReversalScreen extends StatefulWidget {
  const StringReversalScreen({super.key});

  @override
  State<StringReversalScreen> createState() => _StringReversalScreenState();
}

class _StringReversalScreenState extends State<StringReversalScreen> {
  final _controller = TextEditingController();
  String _reversed = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reverse() {
    final input = _controller.text;
    setState(() {
      _reversed = String.fromCharCodes(input.runes.toList().reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('String reversal')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Text to reverse',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _reverse(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _reverse,
              icon: const Icon(Icons.autorenew_rounded),
              label: const Text('Reverse'),
            ),
            const SizedBox(height: 24),
            Text(
              'Result',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SelectableText(
              _reversed.isEmpty ? '—' : _reversed,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
