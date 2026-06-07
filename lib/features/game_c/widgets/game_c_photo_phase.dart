import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/game_c_state.dart';
import '../photo/game_c_photo_provider.dart';
import 'game_c_hud.dart';

class GameCPhotoPhase extends StatelessWidget {
  final GameCState state;
  final GameCPhotoProvider photoProvider;
  final VoidCallback onStartGuessing;
  final VoidCallback onEndGame;

  const GameCPhotoPhase({
    super.key,
    required this.state,
    required this.photoProvider,
    required this.onStartGuessing,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    final target = state.targetZone!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GameCHud(state: state, onEndGame: onEndGame),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Foto ───────────────────────────────────────────────
              photoProvider.buildPhotoGallery(
                target.id,
                height: screenHeight * 0.65,
              ),

              // ── Gradient leggibilità ────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 160,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(217),
                      ],
                    ),
                  ),
                ),
              ),

              // ── CTA in fondo ────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AreaChip(),
                      const SizedBox(height: 8),
                      Text(
                        'Dove si trova\nquest\'area di attesa?',
                        style: AppTextStyles.heading1.copyWith(fontSize: 24, color: AppColors.onColored),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onStartGuessing,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Vai alla mappa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gameC,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: AppTextStyles.button.copyWith(
                              fontSize: 16,
                            ),
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
      ],
    );
  }
}

class _AreaChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gameC.withAlpha(204),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'AREA DI ATTESA',
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }
}