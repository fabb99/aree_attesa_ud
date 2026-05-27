import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/hex_grid_layer.dart';
import '../models/game_b_state.dart';
import '../providers/game_b_provider.dart';
import 'game_b_result_screen.dart';

class GameBRoundResultScreen extends ConsumerStatefulWidget {
  const GameBRoundResultScreen({super.key});

  @override
  ConsumerState<GameBRoundResultScreen> createState() =>
      _GameBRoundResultScreenState();
}

class _GameBRoundResultScreenState
    extends ConsumerState<GameBRoundResultScreen> {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameBProvider);
    final lastRound = state.completedRounds.last;
    final isLastRound = state.phase == GameBPhase.finished;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A14),
        body: Stack(
          children: [
            // ── Mappa con griglia del round appena terminato ────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: lastRound.targetZone.position,
                initialZoom: 14.5,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
                onMapEvent: (event) {
                  if (mounted) {
                    setState(() => _currentCamera = _mapController.camera);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.aree_attesa_ud',
                ),
                // Marker sulla posizione reale dell'area
                MarkerLayer(
                  markers: [
                    Marker(
                      point: lastRound.targetZone.position,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF4CAF50),
                        size: 44,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      
            // ── Griglia ─────────────────────────────────────────────────
            if (_currentCamera != null)
              IgnorePointer(
                ignoring: true,
                child: HexGridLayer(
                  cells: state.cells,
                  camera: _currentCamera!,
                ),
              ),
      
            // ── Pannello risultato round ─────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _RoundResultPanel(
                state: state,
                isLastRound: isLastRound,
                onNext: () => _onNext(state, isLastRound),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNext(GameBState state, bool isLastRound) {
    if (isLastRound) {
      // Vai ai risultati finali — rimuove tutto lo stack fino alla home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GameBResultScreen()),
        (route) => route.isFirst,
      );
    } else {
      ref.read(gameBProvider.notifier).nextRound();
      Navigator.of(context).pop(); // torna a game_b_screen per il prossimo round
    }
  }
}

// ── Pannello risultato ─────────────────────────────────────────────────────────

class _RoundResultPanel extends StatelessWidget {
  final GameBState state;
  final bool isLastRound;
  final VoidCallback onNext;

  const _RoundResultPanel({
    required this.state,
    required this.isLastRound,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final lastRound = state.completedRounds.last;
    final scoreColor = _scoreColor(lastRound.score);

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
        border: Border(
          top: BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                lastRound.tapsUsed == 1
                    ? Icons.emoji_events_rounded
                    : Icons.check_circle_outline,
                color: scoreColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _roundLabel(lastRound.score),
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Round ${state.currentRound}/${state.totalRounds} completato',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
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
                const Text(
                  'AREA DI ATTESA',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastRound.targetZone.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lastRound.targetZone.address,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stats round
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Tentativi usati',
                  value: '${lastRound.tapsUsed}',
                  icon: Icons.touch_app,
                  color: lastRound.tapsUsed == 1
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFFEB3B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                  label: 'Punti round',
                  value: '${lastRound.score}',
                  icon: Icons.star_rounded,
                  color: scoreColor,
                ),
              ),
              const SizedBox(width: 12),
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
              icon: Icon(
                isLastRound ? Icons.bar_chart_rounded : Icons.arrow_forward,
              ),
              label: Text(
                isLastRound ? 'Vedi risultati finali' : 'Prossimo round',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roundLabel(int score) {
    if (score >= 900) return '🎯 Perfetto al primo colpo!';
    if (score >= 600) return '👍 Ottimo!';
    if (score >= 300) return '📚 Ci sei quasi!';
    return '💪 Continua a esplorare!';
  }

  Color _scoreColor(int score) {
    if (score >= 800) return const Color(0xFF4CAF50);
    if (score >= 500) return const Color(0xFFFFEB3B);
    if (score >= 200) return const Color(0xFFFF9800);
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
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}