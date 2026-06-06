import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ui/app_hud_chip.dart';
import '../models/game_b_state.dart';

class GameBHud extends StatelessWidget {
  final GameBState state;
  final VoidCallback onEndGame;

  const GameBHud({
    super.key,
    required this.state,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    return AppHudContainer(
      children: [
        AppHudChip(
          icon: Icons.flag_rounded,
          label: 'Round',
          value: '${state.currentRound + 1}/${state.totalRounds}',
          color: AppColors.gameBLight,
        ),
        const AppHudDivider(),
        AppHudChip(
          icon: Icons.touch_app,
          label: 'Tentativi',
          value: '${state.wrongTaps}',
          color: state.wrongTaps == 0
              ? AppColors.gameALight
              : AppColors.alertRed,
        ),
        const AppHudDivider(),
        AppHudChip(
          icon: Icons.star_rounded,
          label: 'Punti round',
          value: '${state.currentRoundScore}',
          color: AppColors.gold,
        ),
        const AppHudDivider(),
        AppHudChip(
          icon: Icons.emoji_events_rounded,
          label: 'Totale',
          value: '${state.totalScore}',
          color: AppColors.gold,
        ),
        const AppHudDivider(),
        AppHudEndButton(onTap: onEndGame),
      ],
    );
  }
}