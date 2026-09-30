import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/map/hex_grid_layer.dart';
import '../../../core/widgets/ui/app_score_ring.dart';
import '../../../core/models/hex_cell.dart';
import '../models/game_a_state.dart';
import '../providers/game_a_provider.dart';
import '../widgets/found_zone_banner.dart'; 
import 'game_a_screen.dart';

/// Schermata di riepilogo al termine del Gioco A.
/// Mostra la mappa completa con le aree scoperte/non scoperte e il punteggio.
class GameAResultScreen extends ConsumerStatefulWidget {
  const GameAResultScreen({super.key});

  @override
  ConsumerState<GameAResultScreen> createState() => _GameAResultScreenState();
}

class _GameAResultScreenState extends ConsumerState<GameAResultScreen> {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;

  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    final notifier = ref.read(gameAProvider.notifier);
    final cellId = notifier.findCellAtPoint(latLng);
    // Permette all'utente di cliccare le aree scoperte per leggerne i dettagli
    if (cellId != null) notifier.tapCell(cellId);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameAProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Stack(
          children: [
            // ── Mappa di Sfondo ─────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: AppConstants.udineCenter,
                initialZoom: AppConstants.defaultZoom,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
                onTap: _onMapTap,
                onMapEvent: (_) {
                  if (mounted) {
                    setState(() => _currentCamera = _mapController.camera);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.punti_sicuri_ud',
                ),
                if (_currentCamera != null)
                  IgnorePointer(
                    child: HexGridLayer(
                      cells: gameState.cells,
                      camera: _currentCamera!,
                    ),
                  ),
                MarkerLayer(markers: _buildMarkers(gameState)),
              ],
            ),

            // ── Pannello Punteggio Inferiore ────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ResultPanel(
                gameState: gameState,
                onRestart: _restart,
                onHome: () => _goHome(context),
              ),
            ),

            // ── Dettaglio Area Selezionata ──────────────────────────────
            if (gameState.lastFoundName != null)
              FoundZoneBanner(
                name: gameState.lastFoundName!,
                address: gameState.lastFoundAddress ?? '',
                safeZoneId: gameState.safeZones.firstWhere((sz) => sz.name == gameState.lastFoundName).id,
                onDismiss: () => ref.read(gameAProvider.notifier).clearLastFound(),
              ),
          ],
        ),
      ),
    );
  }

  /// Costruisce i marker (Pin di mappa) per tutte le aree di attesa.
  /// Verde = Trovata dall'utente, Rosso = Non trovata.
  List<Marker> _buildMarkers(GameAState state) {
    return state.safeZones.map((sz) {
      final found = state.cells.any(
        (c) => c.id == sz.cellId && c.state == CellState.found,
      );
      
      return Marker(
        point: sz.position,
        width: 36,
        height: 36,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final cellId = state.cells.firstWhere((c) => c.id == sz.cellId).id;
            ref.read(gameAProvider.notifier).tapCell(cellId);
          },
          child: Icon(
            Icons.location_on,
            color: found ? AppColors.gameALight : AppColors.alertRed,
            size: 36,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      );
    }).toList();
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _restart() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameAScreen()),
    );
  }
}

// ── Pannello Risultati ────────────────────────────────────────────────────────

class _ResultPanel extends StatelessWidget {
  final GameAState gameState;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const _ResultPanel({
    required this.gameState,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final score = gameState.score;
    final found = gameState.foundSafeZones;
    final total = gameState.totalSafeZones;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.gameA, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppScoreRing(value: score, maxValue: 100),
          const SizedBox(height: 12),
          Text(
            _scoreLabel(score), 
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)
          ),
          const SizedBox(height: 4),
          Text(
            'Hai trovato $found su $total aree di attesa',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Mosse usate: ${gameState.movesUsed}/${gameState.totalMoves}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.home,
            label: 'Home',
            onPressed: onHome,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.refresh,
            label: 'Gioca ancora',
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 75) return 'Ottimo';
    if (score >= 50) return 'Eccellente!';
    if (score >= 25) return 'Buon lavoro!';
    if (score >= 15) return 'Continua a imparare!';
    return 'Esplora ancora la città!';
  }
}

// ── Bottone di Azione ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gameA,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }
}