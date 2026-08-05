import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

const String _kOnboardingDone = 'onboarding_done';

class OnboardingScreen extends StatefulWidget {
  final bool manualOpen;

  const OnboardingScreen({super.key, this.manualOpen = false});

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

  static const _pages = [_pageData];

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
            // ── Sfondo decorativo ──────────────────────────────────
            const _BackgroundDecoration(),

            // ── Pagine ────────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
            ),

            // ── Bottone chiudi ─────────────────────────────────────
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

            // ── Indicatori + bottone avanti ────────────────────────
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

// ── Sfondo decorativo ─────────────────────────────────────────────────────────

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
                  AppColors.accentDark.withAlpha(0),
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

// ── Pagina onboarding ─────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _PageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          28,
          MediaQuery.of(context).padding.top + 60,
          28,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icona ───────────────────────────────────────────────
            Center(
              child:
               Container(
                width: double.infinity,//72,
                height: 102,
                
                // decoration: BoxDecoration(
                //   color: data.accentColor.withAlpha(28),
                //   borderRadius: BorderRadius.circular(20),
                //   border: Border.all(
                //     color: data.accentColor.withAlpha(80),
                //     width: 1.5,
                //   ),
                // ),
                //child: Icon(data.icon, color: data.accentColor, size: 34),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Transform.scale(
                    scale: 1.5,
                    child: Image.asset(
                      'assets/logo/sonar cities-07.png',
                      fit: BoxFit.contain,
                      
                      //padding: const EdgeInsets.all(12), // se serve respiro, altrimenti rimuovi
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Tag ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: data.accentColor.withAlpha(30),
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

            // ── Titolo ───────────────────────────────────────────────
            Text(data.title, style: AppTextStyles.heading2),
            const SizedBox(height: 20),

            // ── Divisore ─────────────────────────────────────────────
            Container(
              width: 48,
              height: 3,
              decoration: BoxDecoration(
                color: data.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // ── Corpo ────────────────────────────────────────────────
            Text(data.body, style: AppTextStyles.bodyWhite),
            const SizedBox(height: 28),

            // ── Bullet points ─────────────────────────────────────────
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

// ── Dot indicatore ────────────────────────────────────────────────────────────

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
        color: active ? AppColors.accentDark : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Bottone avanti ────────────────────────────────────────────────────────────

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

// ── Contenuto pagina ──────────────────────────────────────────────────────────
const _pageData1 = _PageData(
  tag: 'Aree di attesa',
  title: 'Aree di attesa',
  icon: Icons.school_rounded,
  accentColor: AppColors.accentDark,
  body:
      'Le aree di attesa sono individuate dalla Protezione Civile e '
      'riportate nel Piano Comunale di Protezione Civile, la guida che '
      'ti aiuta a essere pront@ in caso di emergenza!',
  bullets: [],
);


const _pageData5 = _PageData(
  tag: 'A disaster strikes',
  title: 'A disaster strikes. You have minutes to act. Do you know where to go?',
  icon: Icons.school_rounded,
  accentColor: AppColors.accentDark,
  body:
      'Every Italian municipality is required to maintain a '
      ' Municipal Civil Protection Plan, which designates '
      'official emergency assembly areas — safe gathering' 
      'points where residents receive information and first' 
      'assistance in the immediate aftermath of an event. These areas are'
      'formally defined, mapped, and ready. But for most citizens, they'
      'simply do not exist. They have never heard of them.'
      'This serious game changes that. Born from a concrete proposal' 
      'by Udine CSB, it guides users to locate and recognise the assembly'
      'area nearest to them — turning an invisible piece of formal planning'
      'into knowledge that could, one day, save lives.',
    bullets: []
);

const _pageData4 = _PageData(
  tag: 'Aree Attesa UD',
  title: 'Aree Attesa UD',
  icon: Icons.school_rounded,
  accentColor: AppColors.safeNear,
  body:
     'Every Italian municipality '
'is required to maintain a '
'Municipal Civil Protection '
'Plan that identifies official '
'emergency assembly '
'areas for first assistance. '
'Although these areas are '
'formally mapped, most '
'citizens are unaware '
'of them. '
'Born from a proposal by '
'Udine CSB, this serious '
'game helps users locate '
'and recognise these spaces, ' 
'turning an invisible layer '
'of planning into knowledge '
'that saves lives.',

  bullets: [],
);

const _pageData3 = _PageData(
  tag: 'Si verifica un disastro',
  title: 'Si verifica un disastro. Hai pochi minuti per agire. Sai dove andare?',
  icon: Icons.school_rounded,
  accentColor: AppColors.safeNear,
  body:
      'Ogni comune italiano è tenuto a predisporre un '
      'Piano Comunale di Protezione Civile, che individua '
      'le aree di attesa ufficiali per le emergenze — punti '
      'di raccolta sicuri dove i cittadini possono ricevere '
      'informazioni e la prima assistenza subito dopo un evento. '
      'Queste aree sono formalmente definite, mappate e pronte '
      'all’uso. Eppure, per la maggior parte delle persone, è '
      'come se non esistessero: non ne hanno mai sentito parlare. '
      'Questo serious game nasce per cambiare questa situazione. '
      'Ideato a partire da una proposta concreta del CSB di Udine, '
      'guida gli utenti a individuare e riconoscere l’area di attesa '
      'più vicina, trasformando un elemento fondamentale della '
      'pianificazione d’emergenza — spesso invisibile ai cittadini — '
      'in una conoscenza che, un giorno, potrebbe salvare delle vite.',
  bullets: [],
);

// A disaster strikes. You have minutes to act. Do you know where to go?
// 'Every Italian municipality is required to maintain a',
// 'Municipal Civil Protection Plan, which designates', 
// 'official emergency assembly areas — safe gathering', 
// 'points where residents receive information and first', 
// 'assistance in the immediate aftermath of an event. These areas are', 
// 'formally defined, mapped, and ready. But for most citizens, they',
// 'simply do not exist. They have never heard of them.',
// 'This serious game changes that. Born from a concrete proposal', 
// 'by Udine CSB, it guides users to locate and recognise the assembly', 
// 'area nearest to them — turning an invisible piece of formal planning', 
// 'into knowledge that could, one day, save lives.',

const _pageData = _PageData(
  tag: 'PREPARATI ORA',
  title: 'Conosci\nla tua città.',
  icon: Icons.school_rounded,
  accentColor: AppColors.accent,
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