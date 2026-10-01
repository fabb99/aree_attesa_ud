import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/game_c_state.dart';
import '../photo/game_c_photo_provider.dart';
import 'game_c_hud.dart';

/// Fase 1 del round del Gioco C: L'utente osserva le foto dell'area di attesa.
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

    return Column(
      children: [
        GameCHud(state: state, onEndGame: onEndGame),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Galleria Fotografica Dinamica ───────────────────────
              photoProvider.buildPhotoGallery(
                target.id,
                height: double.infinity,
              ),

              // ── Gradiente Scuro in basso per leggibilità testo ──────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 220,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(220),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Titolo e Call To Action ─────────────────────────────
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _AreaChip(),
                    const SizedBox(height: 8),
                    Text(
                      'Dove si trova\nquest\'area di attesa?',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 24, 
                        color: Colors.white, // Forza il bianco sul gradiente nero
                      ),
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
                          textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
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
  const _AreaChip();

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