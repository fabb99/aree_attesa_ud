import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ui/app_end_game_dialog.dart';
import '../../../core/widgets/map/hex_grid_layer.dart';
import '../../../core/widgets/ui/found_zone_banner.dart';
import '../../../core/widgets/ui/tip_banner.dart';        // ← nuovo
import '../../../core/widgets/ui/app_tips.dart';           // ← nuovo
import '../models/game_a_state.dart';
import '../providers/game_a_provider.dart';
import '../widgets/game_a_hud.dart';
import 'game_a_result_screen.dart';

class GameAScreen extends ConsumerStatefulWidget {
  const GameAScreen({super.key});

  @override
  ConsumerState<GameAScreen> createState() => _GameAScreenState();
}

class _GameAScreenState extends ConsumerState<GameAScreen> {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;

  // ── Tip state (locale alla screen, non serve nel provider) ────────────────
  AppTip? _activeTip;
  String? _lastTipId; // per non ripetere la stessa tip due volte di fila

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _startGame());
  }

  Future<void> _startGame() async {
    await ref.read(gameAProvider.notifier).initGame(
          gridRepo: ref.read(gridRepositoryProvider),
          szRepo: ref.read(safeZoneRepositoryProvider),
        );
  }

  Future<void> _onEndGameRequested() async {
    final confirmed = await AppEndGameDialog.show(context);
    if (confirmed && mounted) {
      ref.read(gameAProvider.notifier).endGame();
      _navigateToResults();
    }
  }

  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    final gameState = ref.read(gameAProvider);
    if (gameState.phase != GameAPhase.playing) return;

    final notifier = ref.read(gameAProvider.notifier);
    final cellId = notifier.findCellAtPoint(latLng);
    if (cellId != null) notifier.tapCell(cellId);

    // Controlla se il notifier ha alzato il flag showTip
    final newState = ref.read(gameAProvider);
    if (newState.showTip) {
      _showTip();
      notifier.clearShowTip();
    }

    if (newState.phase == GameAPhase.finished) {
      _navigateToResults();
    }
  }

  void _showTip() {
    final tip = AppTips.pickRandom('gameA', excludeId: _lastTipId);
    _lastTipId = tip.id;
    setState(() => _activeTip = tip);
  }

  void _navigateToResults() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameAResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameAProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Mappa ────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: AppConstants.udineCenter,
                initialZoom: 14.0,
                minZoom: AppConstants.minZoom,
                maxZoom: AppConstants.maxZoom,
                onTap: _onMapTap,
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
                  userAgentPackageName: 'com.example.punti_sicuri_ud',
                ),
              ],
            ),

            // ── Griglia esagonale ────────────────────────────────────
            if (_currentCamera != null &&
                gameState.phase == GameAPhase.playing)
              IgnorePointer(
                child: HexGridLayer(
                  cells: gameState.cells,
                  camera: _currentCamera!,
                ),
              ),

            // ── HUD ──────────────────────────────────────────────────
            if (gameState.phase == GameAPhase.playing)
              GameAHud(
                state: gameState,
                onEndGame: _onEndGameRequested,
              ),

            // ── Banner area trovata ───────────────────────────────────
            if (gameState.lastFoundName != null)
              FoundZoneBanner(
                name: gameState.lastFoundName!,
                address: gameState.lastFoundAddress ?? '',
                safeZoneId: gameState.safeZones.firstWhere((sz) => sz.name == gameState.lastFoundName).id,
                onDismiss: () =>
                    ref.read(gameAProvider.notifier).clearLastFound(),
              ),

            // ── Tip banner ───────────────────────────────────────────
            if (_activeTip != null)
              TipBanner(
                tip: _activeTip!,
                onDismiss: () => setState(() => _activeTip = null),
              ),

            // ── Loading ───────────────────────────────────────────────
            if (gameState.phase == GameAPhase.loading)
              const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

// ── Loading overlay ───────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xCC000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.gameALight),
            SizedBox(height: 16),
            Text(
              'Caricamento mappa...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}