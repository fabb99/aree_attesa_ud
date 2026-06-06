import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ui/app_hud_chip.dart';
import '../models/game_a_state.dart';

class GameAHud extends StatelessWidget {
  final GameAState state;
  final VoidCallback onEndGame;

  const GameAHud({
    super.key,
    required this.state,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    return AppHudContainer(
      children: [
        AppHudChip(
          icon: Icons.touch_app,
          label: 'Mosse',
          value: '${state.movesLeft}',
          color: _movesColor(state.movesLeft, state.totalMoves),
        ),
        const AppHudDivider(),
        AppHudChip(
          icon: Icons.location_on,
          label: 'Trovate',
          value: '${state.foundSafeZones}/${state.totalSafeZones}',
          color: AppColors.gameALight,
        ),
        const AppHudDivider(),
        AppHudChip(
          icon: Icons.star,
          label: 'Punti',
          value: '${state.score}',
          color: AppColors.gold,
        ),
        const AppHudDivider(),
        AppHudEndButton(onTap: onEndGame),
      ],
    );
  }

  Color _movesColor(int left, int total) {
    if (total == 0) return AppColors.textPrimary;
    final ratio = left / total;
    if (ratio > 0.5) return AppColors.gameALight;
    if (ratio > 0.25) return AppColors.warningYellow;
    return AppColors.alertRed;
  }
}