import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../game_a/screens/game_a_screen.dart';
import '../game_b/screens/game_b_screen.dart';
import '../game_c/screens/game_c_screen.dart';
import 'widgets/game_card.dart';
import 'widgets/home_header.dart';
import 'widgets/preparati_card.dart';
import 'guide_screen.dart';
import 'onboarding_screen.dart';

import 'widgets/sonar_wave_header.dart';



//-----------VECCHIA VERSIONE------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOnboarding());
  }

  Future<void> _checkOnboarding() async {
    if (await OnboardingScreen.shouldShow()) {
      if (mounted) _openOnboarding(manual: false);
    }
  }

  void _openOnboarding({bool manual = true}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => OnboardingScreen(manualOpen: manual),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openGuide(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuideScreen(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep, // Sfondo grigio/bianco chiaro
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // ─── ZONA ONDA (Solo Logo e Titolo) ─────────────────────────────
            SonarWaveHeader(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // LOGO
                      Container(
                        width: 150, // Ridotto leggermente per bilanciarlo nell'header stretto
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/logo/sonar cities-04.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // TITOLO BIANCO SUL BLU
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aree Attesa UD', 
                              style: AppTextStyles.heading3App.copyWith(color: AppColors.white),
                            ),
                          
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── ZONA BIANCA (Descrizione, Preparati, Giochi) ───────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Testi principali con il colore scuro del tema Light
                  const Text('Impara a conoscere\nla tua città', style: AppTextStyles.heading1),
                  const SizedBox(height: 12),
                  const Text(
                    'Le aree di attesa sono individuate dalla Protezione Civile e '
                    'riportate nel Piano Comunale di Protezione Civile, la guida che '
                    'ti aiuta a essere pront@ in caso di emergenza!\n\n'
                    'Tre giochi per esplorare le aree di attesa '
                    'della Protezione Civile di Udine.',
                    style: AppTextStyles.body, // Assicurati che qui ci sia "body" e non "bodyWhite"
                  ),
                  
                  const SizedBox(height: 24),
                  PreparatiCard(onTap: () => _openOnboarding(manual: true)),
                  const SizedBox(height: 32),
                  
                  const Text('SCEGLI LA MODALITÀ', style: AppTextStyles.labelAccent),
                  const SizedBox(height: 16),
                  
                  // --- Le tue 3 GameCard qui (esattamente come le avevi prima) ---
                  SizedBox(
                    height: 260,
                    child: GameCard(
                      label: 'GIOCO A',
                      title: 'Campo\nFiorito',
                      description: 'Esplora la mappa di Udine e scopri le aree di attesa della Protezione Civile.',
                      icon: Icons.grid_on_rounded,
                      accentColor: AppColors.gameA,
                      highlightColor: AppColors.gameALight,
                      badgeText: 'Esplora',
                      onTap: () => _navigate(const GameAScreen()),
                      onGuide: () => _openGuide(0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 260,
                    child: GameCard(
                      label: 'GIOCO B',
                      title: 'Localizza\nl\'Area',
                      description: 'Ti viene mostrato il nome di un\'area di attesa: indovina dove si trova.',
                      icon: Icons.my_location_rounded,
                      accentColor: AppColors.gameB,
                      highlightColor: AppColors.gameBLight,
                      badgeText: 'Localizza',
                      onTap: () => _navigate(const GameBScreen()),
                      onGuide: () => _openGuide(1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 260,
                    child: GameCard(
                      label: 'GIOCO C',
                      title: 'GeoGuesser\nUdine',
                      description: 'Osserva le foto di un\'area di attesa e posiziona un pin sulla mappa.',
                      icon: Icons.photo_camera_outlined,
                      accentColor: AppColors.gameC,
                      highlightColor: AppColors.gameCLight,
                      badgeText: 'Riconosci',
                      onTap: () => _navigate(const GameCScreen()),
                      onGuide: () => _openGuide(2),
                    ),
                  ),

                  // Footer
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Sviluppata da Alessandro Fabbri per l\'Università di Udine\n',
                            style: AppTextStyles.caption.copyWith(fontSize: 10, color: const Color(0xFF9999BB)),
                          ),
                          TextSpan(
                            text: '© OpenStreetMap contributors · Dati: Protezione Civile FVG',
                            style: AppTextStyles.caption.copyWith(fontSize: 10, color: const Color(0xFF9999BB)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build1(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 24),
              PreparatiCard(onTap: () => _openOnboarding()),
              const SizedBox(height: 32),
              const Text('SCEGLI LA MODALITÀ', style: AppTextStyles.labelAccent),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: GameCard(
                  label: 'GIOCO A',
                  title: 'Campo\nFiorito',
                  description:
                      'Esplora la mappa di Udine e scopri le aree di attesa '
                      'della Protezione Civile. Usa i colori come guida.',
                  icon: Icons.grid_on_rounded,
                  accentColor: AppColors.gameA,
                  highlightColor: AppColors.gameALight,
                  badgeText: '🌸 Esplora',
                  onTap: () => _navigate(const GameAScreen()),
                  onGuide: () => _openGuide(0),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: GameCard(
                  label: 'GIOCO B',
                  title: 'Localizza\nl\'Area',
                  description:
                      'Ti viene mostrato il nome di un\'area di attesa: '
                      'indovina dove si trova cliccando sulla mappa esagonale.',
                  icon: Icons.my_location_rounded,
                  accentColor: AppColors.gameB,
                  highlightColor: AppColors.gameBLight,
                  badgeText: '📍 Localizza',
                  onTap: () => _navigate(const GameBScreen()),
                  onGuide: () => _openGuide(1),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: GameCard(
                  label: 'GIOCO C',
                  title: 'GeoGuesser\nUdine',
                  description:
                      'Osserva le foto di un\'area di attesa e posiziona '
                      'un pin sulla mappa nel punto più vicino possibile.',
                  icon: Icons.photo_camera_outlined,
                  accentColor: AppColors.gameC,
                  highlightColor: AppColors.gameCLight,
                  badgeText: '📸 GeoGuesser',
                  onTap: () => _navigate(const GameCScreen()),
                  onGuide: () => _openGuide(2),
                ),
              ),

             


              const SizedBox(height: 24),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Sviluppata da Alessandro Fabbri per l\'Università di Udine\n',
                        style: AppTextStyles.caption.copyWith(fontSize: 10, color: Color(0xFF9999BB)) // grigio chiaro
,
                      ),
                      TextSpan(
                        text: '© OpenStreetMap contributors · Dati: Protezione Civile FVG',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                           color: Color(0xFF9999BB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}