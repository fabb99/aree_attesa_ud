import 'package:flutter/material.dart';
import '../game_a/screens/game_a_screen.dart';
import '../game_b/screens/game_b_screen.dart';
import '../game_c/screens/game_c_screen.dart';
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
    // Controlla al primo frame se mostrare l'onboarding
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
        pageBuilder: (_, __, ___) =>
            OnboardingScreen(manualOpen: manual),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                _AppHeader(
                  onGuide: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GuideScreen()),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Banner "Preparati" ────────────────────────────────────
                _PreparatiCard(onTap: () => _openOnboarding()),
                const SizedBox(height: 32),

                // ── Sottotitolo sezione ───────────────────────────────────
                const Text(
                  'SCEGLI LA MODALITÀ',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card Gioco A ──────────────────────────────────────────
                SizedBox(
                  height: 260,
                  child: _GameCard(
                    label: 'GIOCO A',
                    title: 'Campo\nFiorito',
                    description:
                        'Esplora la mappa di Udine e scopri le aree di attesa della Protezione Civile. Usa i colori come guida.',
                    icon: Icons.grid_on_rounded,
                    accentColor: const Color(0xFF2E7D32),
                    highlightColor: const Color(0xFF4CAF50),
                    badgeText: '🌸 Esplora',
                    onTap: () => _navigate(context, const GameAScreen()),
                    onGuide: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const GuideScreen(initialIndex: 0),
    ),
  ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card Gioco B ──────────────────────────────────────────
                SizedBox(
                  height: 260,
                  child: _GameCard(
                    label: 'GIOCO B',
                    title: 'Localizza\nl\'Area',
                    description:
                        'Ti viene mostrato il nome di un\'area di attesa: indovina dove si trova cliccando sulla mappa esagonale.',
                    icon: Icons.my_location_rounded,
                    accentColor: const Color(0xFF1565C0),
                    highlightColor: const Color(0xFF42A5F5),
                    badgeText: '📍 Localizza',
                    onTap: () => _navigate(context, const GameBScreen()),
                    onGuide: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const GuideScreen(initialIndex: 1),
    ),
  ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card Gioco C ──────────────────────────────────────────
                SizedBox(
                  height: 260,
                  child: _GameCard(
                    label: 'GIOCO C',
                    title: 'GeoGuesser\nUdine',
                    description:
                        'Osserva le foto di un\'area di attesa e posiziona un pin sulla mappa nel punto più vicino possibile.',
                    icon: Icons.photo_camera_outlined,
                    accentColor: const Color(0xFF6A1B9A),
                    highlightColor: const Color(0xFFCE93D8),
                    badgeText: '📸 GeoGuesser',
                    onTap: () => _navigate(context, const GameCScreen()),
                    onGuide: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const GuideScreen(initialIndex: 2),
    ),
  ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Footer attribuzione ───────────────────────────────────
                const Center(
                  child: Text(
                    '© OpenStreetMap contributors · Dati: Protezione Civile FVG',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

// ── Banner "Preparati" ─────────────────────────────────────────────────────────

class _PreparatiCard extends StatefulWidget {
  final VoidCallback onTap;
  const _PreparatiCard({required this.onTap});

  @override
  State<_PreparatiCard> createState() => _PreparatiCardState();
}

class _PreparatiCardState extends State<_PreparatiCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B0000), Color(0xFFB71C1C)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.crisis_alert_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preparati all\'emergenza',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Cosa fare in caso di terremoto · Le aree di attesa',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header dell'app ────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  final VoidCallback onGuide;

  const _AppHeader({required this.onGuide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_city,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aree Attesa UD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Protezione Civile · Udine',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: 'Come si gioca',
              child: GestureDetector(
                onTap: onGuide,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withAlpha(30),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white60,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Impara a conoscere\nla tua città',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tre giochi per esplorare le aree di attesa\ndella Protezione Civile di Udine.',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Card singolo gioco ─────────────────────────────────────────────────────────

class _GameCard extends StatefulWidget {
  final String label;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color highlightColor;
  final String badgeText;
  final VoidCallback onTap;
  final VoidCallback onGuide;

  const _GameCard({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.highlightColor,
    required this.badgeText,
    required this.onTap,
    required this.onGuide
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _pressed = false;
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF111811),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withAlpha(128),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withAlpha(38),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.highlightColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.accentColor.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        widget.badgeText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.highlightColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    GestureDetector(
      onTap: widget.onGuide,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.accentColor.withAlpha(128)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline_rounded,
                color: widget.highlightColor, size: 16),
            const SizedBox(width: 6),
            Text(
              'Come si gioca',
              style: TextStyle(
                color: widget.highlightColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(width: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Gioca',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}