import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_c_state.dart';
import '../providers/game_c_provider.dart';

class GameCResultScreen extends ConsumerWidget {
  const GameCResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameCProvider);
    final service = ref.read(gameCProvider.notifier).service;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A14),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header punteggio totale ─────────────────────────────
              _ScoreHeader(state: state),
      
              // ── Lista round ─────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: state.completedRounds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final round = state.completedRounds[index];
                    return _RoundSummaryCard(
                      roundNumber: index + 1,
                      result: round,
                      distLabel: service.formatDistance(round.distanceMeters),
                    );
                  },
                ),
              ),
      
              // ── Bottoni ─────────────────────────────────────────────
              _BottomActions(
                onPlayAgain: () => _playAgain(context, ref),
                onHome: () => _goHome(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playAgain(BuildContext context, WidgetRef ref) {
    ref.read(gameCProvider.notifier).initGame(
          gridRepo: ref.read(gridRepositoryProvider),
          szRepo: ref.read(safeZoneRepositoryProvider),
        );
    Navigator.of(context).pop();
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ScoreHeader extends StatelessWidget {
  final GameCState state;
  const _ScoreHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = state.scorePercentage;
    final color = _scoreColor(pct);
    final avgDist = state.averageDistanceMeters;
    final avgLabel = avgDist < 1000
        ? '${avgDist.round()} m in media'
        : '${(avgDist / 1000).toStringAsFixed(1)} km in media';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'PARTITA CONCLUSA',
            style: TextStyle(
              color: Color(0xFF42A5F5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 16),

          // Ring punteggio
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: pct / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.totalScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('pt',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            _label(pct),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.completedRounds.length} round · max ${state.maxPossibleScore} pt · $avgLabel',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _label(int pct) {
    if (pct >= 90) return '🏆 Esperto del territorio!';
    if (pct >= 60) return '👍 Ottima conoscenza!';
    if (pct >= 30) return '📚 Continua ad esplorare!';
    return '🗺️ Udine ti aspetta!';
  }

  Color _scoreColor(int pct) {
    if (pct >= 60) return const Color(0xFF4CAF50);
    if (pct >= 30) return const Color(0xFFFFEB3B);
    return const Color(0xFFEF5350);
  }
}

// ─── Card round ───────────────────────────────────────────────────────────────

class _RoundSummaryCard extends StatelessWidget {
  final int roundNumber;
  final GameCRoundResult result;
  final String distLabel;

  const _RoundSummaryCard({
    required this.roundNumber,
    required this.result,
    required this.distLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(result.score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Numero round
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withAlpha(51),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF1565C0).withAlpha(128)),
            ),
            child: Center(
              child: Text(
                '$roundNumber',
                style: const TextStyle(
                  color: Color(0xFF42A5F5),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Nome area + distanza
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.targetZone.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.straighten,
                        color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      distLabel,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Punteggio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.score}',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'pt',
                style: TextStyle(
                  color: scoreColor.withAlpha(153),
                  fontSize: 11,
                ),
              ),
            ],
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

// ─── Bottoni ──────────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const _BottomActions({
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.home_rounded),
              label: const Text('Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white60,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onPlayAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Gioca ancora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
