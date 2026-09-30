import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/map/hex_cell_color_mapper.dart';
import '../../../core/widgets/map/hex_grid_layer.dart';
import '../../../core/widgets/ui/app_end_game_dialog.dart';
import '../../../core/widgets/ui/app_tips.dart';
import '../../../core/widgets/ui/tip_banner.dart';
import '../models/game_b_state.dart';
import '../providers/game_b_provider.dart';
import '../widgets/game_b_hud.dart';
import '../widgets/game_b_target_panel.dart';
import 'game_b_result_screen.dart';
import 'game_b_round_result_screen.dart';

/// Schermata principale del "Gioco B - Localizza l'Area".
class GameBScreen extends ConsumerStatefulWidget {
  const GameBScreen({super.key});

  @override
  ConsumerState<GameBScreen> createState() => _GameBScreenState();
}

class _GameBScreenState extends ConsumerState<GameBScreen> {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;
  int? _lastWrongDistance;

  // ── Gestione Tip (locale) ───────────────────────────────────────────────────
  AppTip? _activeTip;
  String? _lastTipId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _startGame());
  }

  Future<void> _startGame() async {
    setState(() => _lastWrongDistance = null);
    await ref.read(gameBProvider.notifier).initGame(
          gridRepo: ref.read(gridRepositoryProvider),
          szRepo: ref.read(safeZoneRepositoryProvider),
        );
  }

  Future<void> _onEndGameRequested() async {
    final confirmed = await AppEndGameDialog.show(context);
    if (confirmed && mounted) {
      ref.read(gameBProvider.notifier).endGame();
      _navigateToResults();
    }
  }

  void _navigateToResults() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameBResultScreen()),
    );
  }

  /// Gestisce il tocco sulla mappa
  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    final state = ref.read(gameBProvider);
    if (state.phase != GameBPhase.playing) return;

    final notifier = ref.read(gameBProvider.notifier);
    final cellId = notifier.findCellAtPoint(latLng);
    if (cellId == null) return;

    final wrongTapsBefore = state.wrongTaps;
    
    // tapCell restituisce true se l'utente ha sbagliato abbastanza volte 
    // da richiedere l'apertura del suggerimento
    final shouldShowTip = notifier.tapCell(cellId);
    final newState = ref.read(gameBProvider);

    // Se il tap è stato errato (numero di errori aumentato)
    if (newState.wrongTaps > wrongTapsBefore) {
      final tappedCell = newState.cells.firstWhere(
        (c) => c.id == cellId,
        orElse: () => newState.cells.first,
      );
      setState(() {
        // Aggiorniamo la UI per mostrare la distanza a cui l'utente ha toccato
        _lastWrongDistance = tappedCell.distanceToNearest;
        if (shouldShowTip) _showTip();
      });
    }

    // Se il tap era corretto (il round o il gioco è finito)
    if (newState.phase == GameBPhase.roundResult ||
        newState.phase == GameBPhase.finished) {
      setState(() => _lastWrongDistance = null);
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GameBRoundResultScreen()),
      );

    }
  }

  void _showTip() {
    final tip = AppTips.pickRandom('gameB', excludeId: _lastTipId);
    _lastTipId = tip.id;
    setState(() => _activeTip = tip);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameBProvider);

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
                initialCenter: AppConstants.udineCenter,
                initialZoom: AppConstants.defaultZoom,
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.aree_attesa_ud',
                ),
              ],
            ),

            // ── Griglia esagonale ────────────────────────────────────
            if (_currentCamera != null && state.phase == GameBPhase.playing)
              IgnorePointer(
                child: HexGridLayer(
                  cells: state.cells,
                  camera: _currentCamera!,
                  // Importante: forza la modalità GameB per colorare in base alla distanza
                  mode: HexGridMode.gameB,
                ),
              ),

            // ── HUD (Punteggi in alto) ───────────────────────────────
            if (state.phase == GameBPhase.playing)
              GameBHud(
                state: state,
                onEndGame: _onEndGameRequested,
              ),

            // ── Pannello Target (Area da trovare in basso) ───────────
            if (state.phase == GameBPhase.playing && state.targetZone != null)
              GameBTargetPanel(
                state: state,
                lastWrongDistance: _lastWrongDistance,
              ),

            // ── Tip banner ───────────────────────────────────────────
            if (_activeTip != null)
              TipBanner(
                tip: _activeTip!,
                onDismiss: () => setState(() => _activeTip = null),
              ),

            // ── Loading ───────────────────────────────────────────────
            if (state.phase == GameBPhase.loading)
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
            CircularProgressIndicator(color: AppColors.gameBLight),
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