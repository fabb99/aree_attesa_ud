import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/game_c_state.dart';
import 'game_c_hud.dart';

class GameCGuessPhase extends StatelessWidget {
  final GameCState state;
  final MapController mapController;
  final MapCamera? currentCamera;
  final ValueChanged<MapCamera> onCameraChanged;
  final Function(TapPosition, LatLng) onMapTap;
  final VoidCallback onConfirm;
  final VoidCallback onEndGame;

  const GameCGuessPhase({
    super.key,
    required this.state,
    required this.mapController,
    required this.currentCamera,
    required this.onCameraChanged,
    required this.onMapTap,
    required this.onConfirm,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    final hasGuess = state.guessPosition != null;

    return Stack(
      children: [
        // ── Mappa ──────────────────────────────────────────────────
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: AppConstants.udineCenter,
            initialZoom: AppConstants.defaultZoom,
            minZoom: 10.0,
            maxZoom: AppConstants.maxZoom,
            onTap: onMapTap,
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
            ),
            onMapEvent: (_) => onCameraChanged(mapController.camera),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.aree_attesa_ud',
            ),
            if (state.guessPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: state.guessPosition!,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.alertRed,
                      size: 48,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        // ── HUD ────────────────────────────────────────────────────
        Positioned(
          top: 0, 
          left: 0, 
          right: 0, 
          child: GameCHud(state: state, onEndGame: onEndGame)
          ),

        // ── Istruzione tap ──────────────────────────────────────────
        if (!hasGuess)
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgDeep.withAlpha(184),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: AppColors.gameCLight,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tocca la mappa per segnare dove \n credi sia l\'area di attesa',
                    //'Tocca la mappa per piazzare il segnalino',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Bottone conferma + nome area ────────────────────────────
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.targetZone != null)
                _TargetNameBox(name: state.targetZone!.name),
              const SizedBox(height: 12),
              _ConfirmButton(hasGuess: hasGuess, onConfirm: onConfirm),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Box nome area ─────────────────────────────────────────────────────────────

class _TargetNameBox extends StatelessWidget {
  final String name;

  const _TargetNameBox({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withAlpha(235),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.gameCLight, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
  }
}

// ── Bottone conferma ──────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool hasGuess;
  final VoidCallback onConfirm;

  const _ConfirmButton({
    required this.hasGuess,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: hasGuess ? onConfirm : null,
        icon: const Icon(Icons.check_rounded),
        label: const Text('Conferma la mia ipotesi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasGuess ? AppColors.gameC : AppColors.bgCardVariant,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.textDisabled,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.button.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}