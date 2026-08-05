import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ui/app_result_actions.dart';
import '../../../core/widgets/ui/app_score_ring.dart';
import '../models/game_c_state.dart';
import '../providers/game_c_provider.dart';
import 'game_c_screen.dart';

class GameCResultScreen extends ConsumerWidget {
  const GameCResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameCProvider);
    final service = ref.read(gameCProvider.notifier).service;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: SafeArea(
          child: Column(
            children: [
              _ScoreHeader(state: state),
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
              AppResultActions(
                primaryColor: AppColors.gameC,
                onHome: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                onPlayAgain: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GameCScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header punteggio ──────────────────────────────────────────────────────────

class _ScoreHeader extends StatelessWidget {
  final GameCState state;

  const _ScoreHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = state.scorePercentage;
    final color = AppScoreRing.colorFor(pct, 100);
    final avgDist = state.averageDistanceMeters;
    final avgLabel = avgDist < 1000
        ? '${avgDist.round()} m in media'
        : '${(avgDist / 1000).toStringAsFixed(1)} km in media';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          bottom: BorderSide(color: AppColors.gameC, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            'PARTITA CONCLUSA',
            style: AppTextStyles.label.copyWith(
              color: AppColors.gameCLight,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          AppScoreRing(
            value: state.totalScore,
            maxValue: state.maxPossibleScore,
            sublabel: 'pt',
          ),
          const SizedBox(height: 12),
          Text(
            _label(pct),
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.completedRounds.length} round · '
            'max ${state.maxPossibleScore} pt · $avgLabel',
            style: AppTextStyles.caption,
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
}

// ── Card round ────────────────────────────────────────────────────────────────

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
    final scoreColor = AppScoreRing.colorFor(result.score, 5000);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _RoundBadge(number: roundNumber),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.targetZone.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.straighten,
                      color: AppColors.textDisabled,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(distLabel, style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.score}',
                style: AppTextStyles.hudValue.copyWith(
                  color: scoreColor,
                  fontSize: 20,
                ),
              ),
              Text(
                'pt',
                style: AppTextStyles.caption.copyWith(
                  color: scoreColor.withAlpha(153),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Badge numero round ────────────────────────────────────────────────────────

class _RoundBadge extends StatelessWidget {
  final int number;

  const _RoundBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.gameC.withAlpha(51),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gameC.withAlpha(128)),
      ),
      child: Center(
        child: Text(
          '$number',
          style: AppTextStyles.buttonSmall.copyWith(
            color: AppColors.gameCLight,
          ),
        ),
      ),
    );
  }
}