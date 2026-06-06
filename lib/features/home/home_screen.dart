import 'package:flutter/material.dart';
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
              Text('SCEGLI LA MODALITÀ', style: AppTextStyles.labelAccent),
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
                child: Text(
                  '© OpenStreetMap contributors · Dati: Protezione Civile FVG',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}