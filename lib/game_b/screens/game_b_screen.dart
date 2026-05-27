import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/app_constants.dart';
import '../../../core/widgets/hex_grid_layer.dart';
import '../../core/widgets/hex_cell_color_mapper.dart';
import '../models/game_b_state.dart';
import '../providers/game_b_provider.dart';
import 'game_b_round_result_screen.dart';
 
class GameBScreen extends ConsumerStatefulWidget {
  const GameBScreen({super.key});
 
  @override
  ConsumerState<GameBScreen> createState() => _GameBScreenState();
}
 
class _GameBScreenState extends ConsumerState<GameBScreen> {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;
 
  // Distanza dell'ultimo tap sbagliato — aggiornata esplicitamente
  // per evitare che _lastDistance legga valori stale dalla lista celle
  int? _lastWrongDistance;
 
  @override
  void initState() {
    super.initState();
    _startGame();
  }
 
  Future<void> _startGame() async {
    setState(() => _lastWrongDistance = null);
    await ref.read(gameBProvider.notifier).initGame(
          gridRepo: ref.read(gridRepositoryProvider),
          szRepo: ref.read(safeZoneRepositoryProvider),
        );
  }
 
  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    final state = ref.read(gameBProvider);
    if (state.phase != GameBPhase.playing) return;
 
    final notifier = ref.read(gameBProvider.notifier);
    final cellId = notifier.findCellAtPoint(latLng);
    if (cellId == null) return;
 
    // Salva il numero di wrongTaps prima del tap
    final wrongTapsBefore = state.wrongTaps;
 
    notifier.tapCell(cellId);
 
    final newState = ref.read(gameBProvider);
 
    // Aggiorna la distanza solo se è un tap sbagliato nuovo
    if (newState.wrongTaps > wrongTapsBefore) {
      // Trova la cella appena rivelata e legge la sua distanza
      final tappedCell = newState.cells.firstWhere(
        (c) => c.id == cellId,
        orElse: () => newState.cells.first,
      );
      setState(() => _lastWrongDistance = tappedCell.distanceToNearest);
    }
 
    // Naviga se il round è finito
    if (newState.phase == GameBPhase.roundResult ||
        newState.phase == GameBPhase.finished) {
      setState(() => _lastWrongDistance = null);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GameBRoundResultScreen()),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameBProvider);
 
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A14),
        body: Stack(
          children: [
            // ── Mappa ──────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: AppConstants.udineCenter,
                initialZoom: 13.5,
                minZoom: 12.0,
                maxZoom: 18.0,
                onTap: _onMapTap,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
                onMapEvent: (event) {
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
       
            // ── Griglia esagonale in modalità Gioco B ───────────────────
            if (_currentCamera != null && state.phase != GameBPhase.loading)
              IgnorePointer(
                ignoring: true,
                child: HexGridLayer(
                  cells: state.cells,
                  camera: _currentCamera!,
                  mode: HexGridMode.gameB, // <-- fix Bug 1
                ),
              ),
       
            // ── HUD round ──────────────────────────────────────────────
            if (state.phase == GameBPhase.playing)
              _GameBHud(state: state),
       
            // ── Pannello target ─────────────────────────────────────────
            if (state.phase == GameBPhase.playing && state.targetZone != null)
              _TargetPanel(
                state: state,
                lastWrongDistance: _lastWrongDistance, // <-- fix Bug 2
              ),
       
            // ── Loading overlay ─────────────────────────────────────────
            if (state.phase == GameBPhase.loading)
              const ColoredBox(
                color: Color(0xCC000000),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF42A5F5)),
                      SizedBox(height: 16),
                      Text(
                        'Caricamento mappa...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
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
 
// ── HUD in alto ────────────────────────────────────────────────────────────────
 
class _GameBHud extends StatelessWidget {
  final GameBState state;
  const _GameBHud({required this.state});
 
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(191),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HudChip(
              icon: Icons.flag_rounded,
              label: 'Round',
              value: '${state.currentRound + 1}/${state.totalRounds}',
              color: const Color(0xFF42A5F5),
            ),
            _divider(),
            _HudChip(
              icon: Icons.touch_app,
              label: 'Tentativi',
              value: '${state.wrongTaps}',
              color: state.wrongTaps == 0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFEF5350),
            ),
            _divider(),
            _HudChip(
              icon: Icons.star_rounded,
              label: 'Punti round',
              value: '${state.currentRoundScore}',
              color: const Color(0xFFFFD700),
            ),
            _divider(),
            _HudChip(
              icon: Icons.emoji_events_rounded,
              label: 'Totale',
              value: '${state.totalScore}',
              color: const Color(0xFFFFD700),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _divider() => Container(width: 1, height: 32, color: Colors.white24);
}
 
class _HudChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
 
  const _HudChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
 
// ── Pannello target in basso ───────────────────────────────────────────────────
 
class _TargetPanel extends StatelessWidget {
  final GameBState state;
  final int? lastWrongDistance;
 
  const _TargetPanel({
    required this.state,
    required this.lastWrongDistance,
  });
 
  @override
  Widget build(BuildContext context) {
    final target = state.targetZone!;
    final hasWrongTap = state.wrongTaps > 0 && lastWrongDistance != null;
 
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF42A5F5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'TROVA QUEST\'AREA DI ATTESA',
                  style: TextStyle(
                    color: Color(0xFF42A5F5),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
 
            // Nome area
            Text(
              target.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
 
            // Indirizzo
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    target.address,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
 
            // Feedback tap
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: hasWrongTap
                    ? const Color(0xFFEF5350).withAlpha(26)
                    : const Color(0xFF1565C0).withAlpha(38),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasWrongTap
                      ? const Color(0xFFEF5350).withAlpha(77)
                      : const Color(0xFF1565C0).withAlpha(77),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasWrongTap ? Icons.wrong_location : Icons.touch_app,
                    color: hasWrongTap
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF42A5F5),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hasWrongTap
                          ? 'Sei a $lastWrongDistance cell${lastWrongDistance == 1 ? 'a' : 'e'} di distanza!'
                          : 'Tocca la cella sulla mappa dove pensi si trovi!',
                      style: TextStyle(
                        color: hasWrongTap
                            ? const Color(0xFFEF5350)
                            : Colors.white70,
                        fontSize: 13,
                        fontWeight: hasWrongTap
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 