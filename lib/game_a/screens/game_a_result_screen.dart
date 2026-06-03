import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/app_constants.dart';
import '../models/game_a_state.dart';
import '../../core/models/hex_cell.dart';
import '../providers/game_a_provider.dart';
import '../../core/widgets/hex_grid_layer.dart';
import '../../core/widgets/found_zone_banner.dart';
import '../screens/game_a_screen.dart';

class GameAResultScreen extends ConsumerStatefulWidget {
  const GameAResultScreen({super.key});

  @override
  ConsumerState<GameAResultScreen> createState() => _GameAResultScreenState();
}

class _GameAResultScreenState extends ConsumerState<GameAResultScreen> {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;

  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    //final gameState = ref.read(gameProvider);
    final notifier = ref.read(gameAProvider.notifier);
    final cellId = notifier.findCellAtPoint(latLng);
    if (cellId != null) {
      notifier.tapCell(cellId);
    }

  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameAProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Stack(
          children: [
            // ─── Mappa con tutte le aree rivelate ─────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(  
                initialCenter: AppConstants.udineCenter,
                initialZoom: 13.5,
                interactionOptions: const InteractionOptions(enableMultiFingerGestureRace: true),
                onTap: _onMapTap,
                onMapEvent: (event) {
                  if (mounted) {
                    setState(() {
                      _currentCamera = _mapController.camera;
                    });
                  }
                },
              
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.punti_sicuri_ud',
                ),
                if (_currentCamera != null)
                  IgnorePointer(
                    ignoring: true,
                    child: HexGridLayer(
                    cells: gameState.cells,
                    camera: _currentCamera!,
                    ),
                  ),
                MarkerLayer(
                  markers: _buildMarkers(gameState),
                ),
              ],
            ),
              
            
            // ─── Pannello risultati ────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ResultPanel(gameState: gameState, onRestart: _restart, onHome: () => _goHome(context),),
            ),
      
            if (gameState.lastFoundName != null)//or
              FoundZoneBanner(
                
                name: gameState.lastFoundName!,
                address: gameState.lastFoundAddress ?? '',
                onDismiss: () =>
                    ref.read(gameAProvider.notifier).clearLastFound(),
              ),
          ],
        ),
      ),
    );
  }

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
            color: found ? const Color(0xFF4CAF50) : Colors.red,
            size: 36,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      );
    }).toList();
  }

  void _goHome(BuildContext context) {
    // Torna alla home rimuovendo tutto lo stack
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _restart() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameAScreen()),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final GameAState gameState;
  final VoidCallback onRestart;
  
  final VoidCallback onHome;//<- aggiunto

  const _ResultPanel({required this.gameState, required this.onRestart, required this.onHome,});

  @override
  Widget build(BuildContext context) {
    final score = gameState.score;
    final found = gameState.foundSafeZones;
    final total = gameState.totalSafeZones;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF2E7D32), width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score ring
          _ScoreRing(score: score),
          const SizedBox(height: 12),
          Text(
            _scoreLabel(score),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hai trovato $found su $total aree di attesa',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Mosse usate: ${gameState.movesUsed}/${gameState.totalMoves}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.home),
              label: const Text('Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Gioca ancora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 80) return '🏆 Eccellente!';
    if (score >= 50) return '👍 Buon lavoro!';
    if (score >= 25) return '📚 Continua a imparare!';
    return 'Esplora ancora la città!';
  }

  
}

class _ScoreRing extends StatelessWidget {
  final int score;

  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(score)),
          ),
          Center(
            child: Text(
              '$score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 50) return const Color(0xFF4CAF50);
    if (score >= 30) return const Color(0xFFFFEB3B);
    if (score >= 15) return const Color(0xFFFF9800);
    return const Color(0xFFEF5350);
  }
}
