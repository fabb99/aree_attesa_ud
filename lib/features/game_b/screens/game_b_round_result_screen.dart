import 'package:aree_attesa_ud/core/widgets/map/hex_cell_color_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/map/hex_grid_layer.dart';
import '../../../core/widgets/ui/app_stat_chip.dart';
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
        backgroundColor: AppColors.bgDeep,
        body: Stack(
          children: [
            // ── Mappa ────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: lastRound.targetZone.position,
                initialZoom: 14.5,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
                onMapEvent: (_) {
                  if (mounted) {
                    setState(() => _currentCamera = _mapController.camera);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.aree_attesa_ud',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: lastRound.targetZone.position,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.gameALight,
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

            // ── Griglia ──────────────────────────────────────────────
            if (_currentCamera != null)
              IgnorePointer(
                child: HexGridLayer(
                  cells: state.cells,
                  camera: _currentCamera!,
                  mode: HexGridMode.gameB
                ),
              ),

            // ── Pannello risultato ────────────────────────────────────
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GameBResultScreen()),
        (route) => route.isFirst,
      );
    } else {
      ref.read(gameBProvider.notifier).nextRound();
      Navigator.of(context).pop();
    }
  }
}

// ── Pannello risultato round ──────────────────────────────────────────────────

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
        24, 20, 24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.gameB, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundHeader(
            score: lastRound.score,
            scoreColor: scoreColor,
            currentRound: state.currentRound,
            totalRounds: state.totalRounds,
            tapsUsed: lastRound.tapsUsed,
          ),
          const SizedBox(height: 16),
          _AreaInfoBox(
            name: lastRound.targetZone.name,
            address: lastRound.targetZone.address,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppStatChip(
                  label: 'Tentativi usati',
                  value: '${lastRound.tapsUsed}',
                  icon: Icons.touch_app,
                  color: lastRound.tapsUsed == 1
                      ? AppColors.gameALight
                      : AppColors.warningYellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppStatChip(
                  label: 'Punti round',
                  value: '${lastRound.score}',
                  icon: Icons.star_rounded,
                  color: scoreColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppStatChip(
                  label: 'Totale',
                  value: '${state.totalScore}',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _NextButton(isLastRound: isLastRound, onNext: onNext),
        ],
      ),
    );
  }

  static Color _scoreColor(int score) {
    if (score >= 800) return AppColors.gameALight;
    if (score >= 500) return AppColors.warningYellow;
    if (score >= 200) return AppColors.warningOrange;
    return AppColors.alertRed;
  }
}

// ── Header round ──────────────────────────────────────────────────────────────

class _RoundHeader extends StatelessWidget {
  final int score;
  final Color scoreColor;
  final int currentRound;
  final int totalRounds;
  final int tapsUsed;

  const _RoundHeader({
    required this.score,
    required this.scoreColor,
    required this.currentRound,
    required this.totalRounds,
    required this.tapsUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          tapsUsed == 1
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
              _roundLabel(score),
              style: AppTextStyles.heading3.copyWith(
                color: scoreColor,
                fontSize: 16,
              ),
            ),
            Text(
              'Round $currentRound/$totalRounds completato',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  String _roundLabel(int score) {
    if (score >= 900) return '🎯 Perfetto al primo colpo!';
    if (score >= 600) return '👍 Ottimo!';
    if (score >= 300) return '📚 Ci sei quasi!';
    return '💪 Continua a esplorare!';
  }
}

// ── Box info area ─────────────────────────────────────────────────────────────

class _AreaInfoBox extends StatelessWidget {
  final String name;
  final String address;

  const _AreaInfoBox({required this.name, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AREA DI ATTESA', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(name, style: AppTextStyles.heading3.copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text(address, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ── Bottone avanti ────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool isLastRound;
  final VoidCallback onNext;

  const _NextButton({required this.isLastRound, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          backgroundColor: AppColors.gameB,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }
}