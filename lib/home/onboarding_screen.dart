import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chiave usata per salvare se l'onboarding è già stato visto.
const String _kOnboardingDone = 'onboarding_done';

/// Mostra l'onboarding solo al primo avvio; poi è richiamabile
/// dalla Home tramite il bottone "Preparati".
///
/// [onFinish] viene chiamato quando l'utente chiude la schermata
/// (bottone "Inizia" o icona X).
class OnboardingScreen extends StatefulWidget {
  /// Se true, non salva il flag "già visto" (usato quando si apre
  /// manualmente dalla Home).
  final bool manualOpen;

  const OnboardingScreen({super.key, this.manualOpen = false});

  /// Controlla se l'onboarding dev'essere mostrato al primo avvio.
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

  //static const _pages = [_pageData1, _pageData2, _pageData3]; 
  //rimosso _pageData1 _pageData2
  static const _pages = [_pageData3];

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
        backgroundColor: const Color(0xFF060D12),
        body: Stack(
          children: [
            // ── Sfondo decorativo ────────────────────────────────────
            const _BackgroundDecoration(),

            // ── Contenuto pagine ─────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
            ),

            // ── Bottone chiudi ────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: IconButton(
                onPressed: _finish,
                icon: const Icon(Icons.close_rounded),
                color: Colors.white38,
                iconSize: 22,
              ),
            ),

            // ── Indicatori + bottone avanti ───────────────────────────
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => _Dot(active: i == _currentPage),
                    ),
                  ),

                  // Bottone avanti / inizia
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

// ─── Sfondo decorativo ────────────────────────────────────────────────────────

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cerchio in alto a sinistra
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
                  const Color(0xFFE53935).withAlpha(45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Cerchio in basso a destra
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
                  const Color(0xFFFF6F00).withAlpha(35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Linea decorativa sottile diagonale
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
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Singola pagina onboarding ────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return  SingleChildScrollView(
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
            // Icona in container stilizzato
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: data.accentColor.withAlpha(28),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: data.accentColor.withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Icon(data.icon, color: data.accentColor, size: 34),
            ),
            const SizedBox(height: 32),
      
            // Numero pagina + etichetta
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.accentColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.tag,
                    style: TextStyle(
                      color: data.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
      
            // Titolo
            Text(
              data.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
      
            // Divisore colorato
            Container(
              width: 48,
              height: 3,
              decoration: BoxDecoration(
                color: data.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
      
            // Corpo testo
            Text(
              data.body,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 28),
      
            // Bullet points (se presenti)
            if (data.bullets.isNotEmpty)
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
                        child: Text(
                          b,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
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

// ─── Dot indicatore ───────────────────────────────────────────────────────────

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
        color: active ? const Color(0xFFE53935) : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Bottone avanti / inizia ──────────────────────────────────────────────────

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
          color: isLast ? const Color(0xFFE53935) : Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLast ? Colors.transparent : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLast ? 'Inizia a giocare' : 'Avanti',
              style: TextStyle(
                color: isLast ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
              color: isLast ? Colors.white : Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dati delle pagine ────────────────────────────────────────────────────────

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

const _pageData1 = _PageData(
  tag: '01 · RISCHIO SISMICO',
  title: 'Il terremoto\nnon si prevede.',
  icon: Icons.crisis_alert_rounded,
  accentColor: Color(0xFFE53935),
  body:
      'I terremoti non possono essere previsti, ma i loro effetti possono essere ridotti attraverso la preparazione e la consapevolezza.\n\n'
      'In caso di terremoto, seguire comportamenti adeguati contribuisce a ridurre i rischi. Ecco le principali indicazioni:',
  bullets: [
    'Durante la scossa: riparati sotto un tavolo robusto o accanto a un muro portante. Allontanati da finestre e oggetti che possono cadere.',
    'Dopo la scossa: esci con calma dall\'edificio, non usare ascensori, attenzione ai detriti.',
    'Raggiungi la tua area di attesa più vicina per ricevere assistenza.',
  ],
);

const _pageData2 = _PageData(
  tag: '02 · AREE DI ATTESA',
  title: 'Il tuo punto\ndi raccolta sicuro.',
  icon: Icons.location_on_rounded,
  accentColor: Color(0xFFFF6F00),
  body:
      'Le aree di attesa sono spazi aperti sicuri — piazze, parchi, parcheggi — '
      'dove la popolazione si raccoglie subito dopo un\'emergenza.\n\n'
      'Nelle aree di attesa troverai le prime informazioni sull\'evento, assistenza della Protezione Civile '
      'e i primi generi di conforto mentre vengono organizzati i soccorsi.',
  bullets: [
    'Sono lontane da edifici che potrebbero crollare e da zone alluvionali.',
    'Sono facilmente raggiungibili a piedi attraverso percorsi sicuri.',
    //'A Udine ne sono state individuate oltre 40, distribuite in tutto il territorio comunale.',
  ],
);

const _pageData3 = _PageData(
  tag: 'PREPARARSI ORA',//'03 · PREPARARSI ORA',
  title: 'Conosci\nla tua città.',
  icon: Icons.school_rounded,
  accentColor: Color(0xFF43A047),
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