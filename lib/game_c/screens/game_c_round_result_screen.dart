import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/game_c_service.dart';
import '../models/game_c_state.dart';
import '../providers/game_c_provider.dart';
import 'game_c_result_screen.dart';
 
class GameCRoundResultScreen extends ConsumerStatefulWidget {
  const GameCRoundResultScreen({super.key});
 
  @override
  ConsumerState<GameCRoundResultScreen> createState() =>
      _GameCRoundResultScreenState();
}
 
class _GameCRoundResultScreenState
    extends ConsumerState<GameCRoundResultScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  // Animazione punteggio (conta da 0 al valore finale)
  late final AnimationController _scoreAnimController;
  late final Animation<int> _scoreAnim;
 
  @override
  void initState() {
    super.initState();
 
    final lastRound = ref.read(gameCProvider).completedRounds.last;
 
    _scoreAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scoreAnim = IntTween(begin: 0, end: lastRound.score).animate(
      CurvedAnimation(parent: _scoreAnimController, curve: Curves.easeOut),
    );
    _scoreAnimController.forward();
 
    // Centra la mappa tra guess e target dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
  }
 
  void _fitBounds() {
    final state = ref.read(gameCProvider);
    final last = state.completedRounds.last;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints([
          last.guessPosition,
          last.targetZone.position,
        ]),
        padding: const EdgeInsets.fromLTRB(60, 120, 60, 320),
      ),
    );
  }
 
  void _onNext() {
    final state = ref.read(gameCProvider);
    final isLast = state.phase == GameCPhase.finished;
 
    if (isLast) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GameCResultScreen()),
        (route) => route.isFirst,
      );
    } else {
      ref.read(gameCProvider.notifier).nextRound();
      Navigator.of(context).pop();
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameCProvider);
    final last = state.completedRounds.last;
    final isLast = state.phase == GameCPhase.finished;
    final service = ref.read(gameCProvider.notifier).service;
 
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A14),
        body: Stack(
          children: [
            // ── Mappa con pin + linea ───────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: last.targetZone.position,
                initialZoom: 13.5,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.aree_attesa_ud',
                ),
 
                // Linea tratteggiata guess → target
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [last.guessPosition, last.targetZone.position],
                      color: Colors.deepOrangeAccent.withValues(alpha: 0.7),
                      strokeWidth: 2.5,
                      pattern: const StrokePattern.dotted(),
                    ),
                  ],
                ),
 
                // Pin guess (rosso)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: last.guessPosition,
                      width: 48,
                      height: 60,
                      child: const _PinWidget(
                        color: Color(0xFFEF5350),
                        label: 'Tu',
                      ),
                    ),
                    // Pin target (verde)
                    Marker(
                      point: last.targetZone.position,
                      width: 48,
                      height: 60,
                      child: const _PinWidget(
                        color: Color(0xFF4CAF50),
                        label: '✓',
                      ),
                    ),
                  ],
                ),
              ],
            ),
 
            // ── Pannello risultato ────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ResultPanel(
                state: state,
                last: last,
                scoreAnim: _scoreAnim,
                isLast: isLast,
                service: service,
                onNext: _onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  @override
  void dispose() {
    _scoreAnimController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
 
// ─── Pin personalizzato con label ────────────────────────────────────────────
 
class _PinWidget extends StatelessWidget {
  final Color color;
  final String label;
 
  const _PinWidget({required this.color, required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                  color: Colors.black38, blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        Icon(Icons.location_on, color: color, size: 36,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)]),
      ],
    );
  }
}
 
// ─── Pannello risultato ───────────────────────────────────────────────────────
 
class _ResultPanel extends StatelessWidget {
  final GameCState state;
  final GameCRoundResult last;
  final Animation<int> scoreAnim;
  final bool isLast;
  final GameCService service;
  final VoidCallback onNext;
 
  const _ResultPanel({
    required this.state,
    required this.last,
    required this.scoreAnim,
    required this.isLast,
    required this.service,
    required this.onNext,
  });
 
  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(last.score);
    final distLabel = service.formatDistance(last.distanceMeters);
    final label = service.scoreLabel(last.score);
 
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF1565C0), width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: scoreColor, size: 26),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: scoreColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(
                    'Round ${state.currentRound}/${state.totalRounds} completato',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
 
          // Info area trovata
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AREA DI ATTESA',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(last.targetZone.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(last.targetZone.address,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
 
          // Stats: distanza + punteggio round + totale
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Distanza',
                  value: distLabel,
                  icon: Icons.straighten,
                  color: const Color(0xFF42A5F5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedBuilder(
                  animation: scoreAnim,
                  builder: (_, __) => _StatChip(
                    label: 'Punti round',
                    value: '${scoreAnim.value}',
                    icon: Icons.star_rounded,
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  label: 'Totale',
                  value: '${state.totalScore}',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
 
          // Bottone avanti
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: Icon(isLast
                  ? Icons.bar_chart_rounded
                  : Icons.arrow_forward_rounded),
              label:
                  Text(isLast ? 'Vedi risultati finali' : 'Prossimo round'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Color _scoreColor(int score) {
    if (score >= 4000) return const Color(0xFF4CAF50);
    if (score >= 2500) return const Color(0xFFFFEB3B);
    if (score >= 1000) return const Color(0xFFFF9800);
    return const Color(0xFFEF5350);
  }
}
 
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
 
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}