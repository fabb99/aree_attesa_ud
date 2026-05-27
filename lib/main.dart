import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/home_screen.dart';  // ← cambia questo

void main() {
  runApp(const ProviderScope(child: AreeAttesaApp()));
}

class AreeAttesaApp extends StatelessWidget {
  const AreeAttesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aree Attesa UD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),  // ← e questo
    );
  }
}