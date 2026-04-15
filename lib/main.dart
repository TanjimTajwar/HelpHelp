import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const SanjidaGoApp());
}

class SanjidaGoApp extends StatelessWidget {
  const SanjidaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanjida Go',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
