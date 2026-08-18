import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/home/home_screen.dart';  
import 'core/theme/app_colors.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.cosmicCobalt),//AppColors.safeFound),
        
        textTheme: GoogleFonts.robotoTextTheme(),
       
        useMaterial3: true,
      ),
      home: const HomeScreen(),  // ← e questo
    );
  }
}