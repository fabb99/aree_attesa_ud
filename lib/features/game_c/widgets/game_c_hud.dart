import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ui/app_hud_chip.dart';
import '../models/game_c_state.dart';

class GameCHud extends StatelessWidget {
  final GameCState state;
  final VoidCallback onEndGame;

  const GameCHud({
    super.key,
    required this.state,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 8,
          20,
          12,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgDark.withAlpha(235),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppHudChip(
              icon: Icons.flag_rounded,
              label: 'Round',
              value: '${state.currentRound + 1}/${state.totalRounds}',
              color: AppColors.gameCLight,
            ),
            AppHudChip(
              icon: Icons.emoji_events_rounded,
              label: 'Totale',
              value: '${state.totalScore}',
              color: AppColors.gold,
            ),
            AppHudEndButton(onTap: onEndGame),
          ],
        ),
      ),
    );
  }
}