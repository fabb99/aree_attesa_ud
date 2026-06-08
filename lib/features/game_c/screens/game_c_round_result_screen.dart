import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ui/app_stat_chip.dart';
import '../../../core/widgets/ui/app_score_ring.dart';
import '../models/game_c_state.dart';
import '../providers/game_c_provider.dart';
import '../services/game_c_service.dart';
import 'game_c_result_screen.dart';

class GameCRoundResultScreen extends ConsumerStatefulWidget {
  const GameCRoundResultScreen({super.key});

  @override
  ConsumerState<GameCRoundResultScreen> createState() =>
      _GameCRoundResultScreenState();
}

class _GameCRoundResultScreenState
    extends ConsumerState<GameCRoundResultScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();

  late final AnimationController _scoreAnimController;
  late final Animation<int> _scoreAnim;

  @override
  void initState() {
    super.initState();

    final lastRound = ref.read(gameCProvider).completedRounds.last;

    _scoreAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scoreAnim = IntTween(begin: 0, end: lastRound.score).animate(
      CurvedAnimation(
        parent: _scoreAnimController,
        curve: Curves.easeOut,
      ),
    );
    _scoreAnimController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
  }

  void _fitBounds() {
    final last = ref.read(gameCProvider).completedRounds.last;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints([
          last.guessPosition,
          last.targetZone.position,
        ]),
        padding: const EdgeInsets.fromLTRB(60, 120, 60, 320),
      ),
    );
  }

  void _onNext() {
    final state = ref.read(gameCProvider);
    if (state.phase == GameCPhase.finished) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GameCResultScreen()),
        (route) => route.isFirst,
      );
    } else {
      ref.read(gameCProvider.notifier).nextRound();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameCProvider);
    final last = state.completedRounds.last;
    final isLast = state.phase == GameCPhase.finished;
    final service = ref.read(gameCProvider.notifier).service;

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
                initialCenter: last.targetZone.position,
                initialZoom: AppConstants.defaultZoom,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.aree_attesa_ud',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        last.guessPosition,
                        last.targetZone.position,
                      ],
                      color: AppColors.warningOrange.withAlpha(178),
                      strokeWidth: 2.5,
                      pattern: const StrokePattern.dotted(),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: last.guessPosition,
                      width: 48,
                      height: 60,
                      child: const _PinWidget(
                        color: AppColors.alertRed,
                        label: 'Tu',
                      ),
                    ),
                    Marker(
                      point: last.targetZone.position,
                      width: 48,
                      height: 60,
                      child: const _PinWidget(
                        color: AppColors.gameALight,
                        label: '✓',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Pannello risultato ────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ResultPanel(
                state: state,
                last: last,
                scoreAnim: _scoreAnim,
                isLast: isLast,
                service: service,
                onNext: _onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}

// ── Pin personalizzato ────────────────────────────────────────────────────────

class _PinWidget extends StatelessWidget {
  final Color color;
  final String label;

  const _PinWidget({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.buttonSmall.copyWith(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
        Icon(
          Icons.location_on,
          color: color,
          size: 36,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
        ),
      ],
    );
  }
}

// ── Pannello risultato ────────────────────────────────────────────────────────

class _ResultPanel extends StatelessWidget {
  final GameCState state;
  final GameCRoundResult last;
  final Animation<int> scoreAnim;
  final bool isLast;
  final GameCService service;
  final VoidCallback onNext;

  const _ResultPanel({
    required this.state,
    required this.last,
    required this.scoreAnim,
    required this.isLast,
    required this.service,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppScoreRing.colorFor(last.score, 5000);
    final distLabel = service.formatDistance(last.distanceMeters);
    final label = service.scoreLabel(last.score);

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
          _ResultHeader(
            label: label,
            scoreColor: scoreColor,
            currentRound: state.currentRound,
            totalRounds: state.totalRounds,
          ),
          const SizedBox(height: 16),
          _AreaInfoBox(
            name: last.targetZone.name,
            address: last.targetZone.address,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppStatChip(
                  label: 'Distanza',
                  value: distLabel,
                  icon: Icons.straighten,
                  color: AppColors.gameBLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedBuilder(
                  animation: scoreAnim,
                  builder: (_, __) => AppStatChip(
                    label: 'Punti round',
                    value: '${scoreAnim.value}',
                    icon: Icons.star_rounded,
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
          _NextButton(isLast: isLast, onNext: onNext),
        ],
      ),
    );
  }
}

// ── Header risultato ──────────────────────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  final String label;
  final Color scoreColor;
  final int currentRound;
  final int totalRounds;

  const _ResultHeader({
    required this.label,
    required this.scoreColor,
    required this.currentRound,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: scoreColor, size: 26),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
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
          const Text('AREA DI ATTESA', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTextStyles.heading3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(address, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ── Bottone avanti ────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onNext;

  const _NextButton({required this.isLast, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onNext,
        icon: Icon(
          isLast ? Icons.bar_chart_rounded : Icons.arrow_forward_rounded,
        ),
        label: Text(isLast ? 'Vedi risultati finali' : 'Prossimo round'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gameC,
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

// ── Costanti locali ───────────────────────────────────────────────────────────

class AppConstants {
  static const defaultZoom = 13.5;
}