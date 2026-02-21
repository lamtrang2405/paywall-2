import 'package:flutter/material.dart';
import 'paywall_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Paywall',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07070C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE63E6D),
          secondary: Color(0xFF7C3AED),
          surface: Color(0xFF0F0F17),
        ),
      ),
      home: const PaywallScreen(),
    );
  }
}
