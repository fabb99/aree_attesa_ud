import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(
    // ProviderScope è necessario per far funzionare Riverpod in tutta l'app
    const ProviderScope(
      child: AreeAttesaApp(),
    ),
  );
}

/// Entry point principale dell'applicazione [AreeAttesaApp].
/// 
/// Configura il tema globale e definisce [HomeScreen] come schermata iniziale.
class AreeAttesaApp extends StatelessWidget {
  const AreeAttesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aree Attesa UD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.cosmicCobalt),
        textTheme: GoogleFonts.robotoTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}