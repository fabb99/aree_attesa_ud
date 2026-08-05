import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ui/app_result_actions.dart';
import '../../../core/widgets/ui/app_score_ring.dart';
import '../models/game_b_state.dart';
import '../providers/game_b_provider.dart';
import 'game_b_screen.dart';

class GameBResultScreen extends ConsumerWidget {
  const GameBResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameBProvider);

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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: state.completedRounds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final round = state.completedRounds[index];
                    return _RoundSummaryCard(
                      roundNumber: index + 1,
                      result: round,
                    );
                  },
                ),
              ),
              AppResultActions(
                primaryColor: AppColors.gameB,
                onHome: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                onPlayAgain: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GameBScreen()),
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
  final GameBState state;

  const _ScoreHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = state.scorePercentage;
    final color = AppScoreRing.colorFor(pct, 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          bottom: BorderSide(color: AppColors.gameB, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            'PARTITA CONCLUSA',
            style: AppTextStyles.label.copyWith(
              color: AppColors.gameBLight,
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
            '${state.completedRounds.length} round completati · '
            'max ${state.maxPossibleScore} pt',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  String _label(int pct) {
    if (pct >= 90) return '🏆 Esperto delle aree di attesa!';
    if (pct >= 60) return '👍 Ottima conoscenza del territorio!';
    if (pct >= 30) return '📚 Continua ad esplorare!';
    return '🗺️ Udine ti aspetta!';
  }
}

// ── Card round ────────────────────────────────────────────────────────────────

class _RoundSummaryCard extends StatelessWidget {
  final int roundNumber;
  final RoundResult result;

  const _RoundSummaryCard({
    required this.roundNumber,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppScoreRing.colorFor(result.score, 1000);

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
                Text(
                  '${result.tapsUsed} '
                  'tentativ${result.tapsUsed == 1 ? 'o' : 'i'}',
                  style: AppTextStyles.caption,
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
        color: AppColors.gameB.withAlpha(51),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gameB.withAlpha(128)),
      ),
      child: Center(
        child: Text(
          '$number',
          style: AppTextStyles.buttonSmall.copyWith(
            color: AppColors.gameBLight,
          ),
        ),
      ),
    );
  }
}