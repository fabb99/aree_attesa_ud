import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/app_constants.dart';
import '../models/game_a_state.dart';
import '../providers/game_a_provider.dart';
import '../../core/widgets/found_zone_banner.dart';
import '../widgets/game_a_hud.dart';
import '../../core/widgets/hex_grid_layer.dart';
import 'game_a_result_screen.dart';

/// Centro della mappa: Udine
class GameAScreen extends ConsumerStatefulWidget {
  const GameAScreen({super.key});

  @override
  ConsumerState<GameAScreen> createState() => _GameAScreenState();
}

class _GameAScreenState extends ConsumerState<GameAScreen> {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  Future<void> _startGame() async {
    final notifier = ref.read(gameAProvider.notifier);
    await notifier.initGame(
      gridRepo: ref.read(gridRepositoryProvider),
      szRepo: ref.read(safeZoneRepositoryProvider),
    );
  }

  Future<void> _onEndGameRequested() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.flag, color: Color(0xFFEF5350), size: 24),
            SizedBox(width: 10),
            Text(
              'Termina partita',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Vuoi terminare la partita adesso?\nTutte le aree di attesa non ancora trovate verranno rivelate.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          // Annulla
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white60,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Annulla'),
          ),
          // Conferma
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Termina', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
 
    if (confirmed == true && mounted) {
      ref.read(gameAProvider.notifier).endGame();
      _navigateToResults();
    }
  }

  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    final gameState = ref.read(gameAProvider);
    if (gameState.phase != GameAPhase.playing) return;

    final notifier = ref.read(gameAProvider.notifier);
    final cellId = notifier.findCellAtPoint(latLng);
    if (cellId != null) {
      notifier.tapCell(cellId);
    }

    // Controlla se il gioco è finito dopo il tap
    final newState = ref.read(gameAProvider);
    if (newState.phase == GameAPhase.finished) {
      _navigateToResults();
    }
  }

  void _navigateToResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameAResultScreen(),
      ),
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
            // ─── Mappa flutter_map ─────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: AppConstants.udineCenter,
                initialZoom: 14.0,
                minZoom: 12.0,
                maxZoom: 18.0,
                onTap: _onMapTap,
                interactionOptions: const InteractionOptions(enableMultiFingerGestureRace: true),
                onMapEvent: (event) {
                  if (mounted) {
                    setState(() {
                      _currentCamera = _mapController.camera;
                    });
                  }
                },
              ),
              children: [
                // Tile layer OpenStreetMap
                TileLayer(
                  urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  //urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.punti_sicuri_ud',
                ),
      
                // Griglia esagonale sovrapposta
                if (_currentCamera != null &&
                    gameState.phase != GameAPhase.loading)
                    const OverlayImageLayer(       
                      overlayImages: [],
                    ),
              ],
            ),
      
            // ─── CustomPainter griglia sopra la mappa ─────────────────────
            // ignoring: true → la griglia è solo visuale, i touch passano
            // a flutter_map che li gestisce tramite onTap nelle MapOptions
            if (_currentCamera != null && gameState.phase != GameAPhase.loading)
              IgnorePointer(
                ignoring: true,
                child: HexGridLayer(
                  cells: gameState.cells,
                  camera: _currentCamera!,
                ),
              ),
      
            // ─── HUD ───────────────────────────────────────────────────────
            if (gameState.phase == GameAPhase.playing)
              GameAHUD(state: gameState, onEndGame: _onEndGameRequested),
      
            // ─── Banner area trovata ───────────────────────────────────────
            if (gameState.lastFoundName != null)//or
              FoundZoneBanner(
                name: gameState.lastFoundName!,
                address: gameState.lastFoundAddress ?? '',
                onDismiss: () =>
                    ref.read(gameAProvider.notifier).clearLastFound(),
              ),
      
            // ─── Loading overlay ───────────────────────────────────────────
            if (gameState.phase == GameAPhase.loading)
              const ColoredBox(
                color: Color(0xCC000000),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF4CAF50)),
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
