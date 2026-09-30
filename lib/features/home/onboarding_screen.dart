import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

const String _kOnboardingDone = 'onboarding_done';

/// Schermata di benvenuto e introduzione (Onboarding).
///
/// Viene mostrata automaticamente solo al primo avvio dell'app grazie 
/// all'uso di [SharedPreferences], oppure manualmente se richiamata dalla Home.
class OnboardingScreen extends StatefulWidget {
  final bool manualOpen;

  const OnboardingScreen({super.key, this.manualOpen = false});

  /// Controlla se l'onboarding deve essere mostrato (primo avvio).
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_kOnboardingDone) ?? false);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  // Dati della singola pagina di onboarding (espandibile in futuro)
  static const _pages = [_onboardingContent];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  Future<void> _finish() async {
    if (!widget.manualOpen) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboardingDone, true);
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Stack(
          children: [
            const _BackgroundDecoration(),
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: IconButton(
                onPressed: _finish,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textDisabled,
                iconSize: 22,
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => _Dot(active: i == _currentPage),
                    ),
                  ),
                  _NextButton(
                    isLast: _currentPage == _pages.length - 1,
                    onTap: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Decorazioni visive ────────────────────────────────────────────────────────

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.cosmicCobalt.withAlpha(25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentDark.withAlpha(35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _DiagonalLinePainter()),
        ),
      ],
    );
  }
}

class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..strokeWidth = 1;
    for (int i = -5; i < 20; i++) {
      final x = i * 60.0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── Componenti di pagina ──────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _PageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          28, MediaQuery.of(context).padding.top + 60, 28, 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: 102,
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Transform.scale(
                    scale: 1.5,
                    child: Image.asset(
                      'assets/logo/sonar cities-07.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: data.accentColor.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data.tag,
                style: AppTextStyles.label.copyWith(
                  color: data.accentColor,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(data.title, style: AppTextStyles.heading2),
            const SizedBox(height: 20),
            Container(
              width: 48,
              height: 3,
              decoration: BoxDecoration(
                color: data.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(data.body, style: AppTextStyles.bodyWhite),
            const SizedBox(height: 28),
            ...data.bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: data.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(b, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6),
      width: active ? 24 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.transparent, 
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;

  const _NextButton({required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isLast ? AppColors.accentDark : AppColors.bgCardVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLast ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLast ? 'Inizia a giocare' : 'Avanti',
              style: AppTextStyles.button.copyWith(
                color: isLast ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
              color: isLast ? Colors.white : AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _PageData {
  final String tag;
  final String title;
  final String body;
  final List<String> bullets;
  final IconData icon;
  final Color accentColor;

  const _PageData({
    required this.tag,
    required this.title,
    required this.body,
    required this.bullets,
    required this.icon,
    required this.accentColor,
  });
}

const _onboardingContent = _PageData(
  tag: 'PREPARATI ORA',
  title: 'Conosci\nla tua città.',
  icon: Icons.school_rounded,
  accentColor: AppColors.cosmicCobalt,
  body:
      'La preparazione è la migliore forma di protezione. '
      'Sapere dove si trovano le aree di attesa vicino a casa tua, al lavoro, '
      'a scuola può fare la differenza in un momento di panico.\n\n'
      'Questa app ti aiuta a imparare giocando — tre modalità diverse '
      'per esplorare e memorizzare le aree di attesa di Udine.',
  bullets: [
    'Campo Fiorito: scopri le aree nascoste sulla griglia esplorando la città.',
    'Localizza l\'Area: trova sulla mappa l\'area indicata per nome e indirizzo.',
    'GeoGuesser: riconosci le aree dalle fotografie e indovina dove si trovano.',
  ],
);