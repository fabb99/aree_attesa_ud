import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/app_constants.dart';
import '../models/game_c_state.dart';
import '../providers/game_c_provider.dart';
import '../photo/game_c_photo_provider.dart';
import 'game_c_round_result_screen.dart';

class GameCScreen extends ConsumerStatefulWidget {
  const GameCScreen({super.key});

  @override
  ConsumerState<GameCScreen> createState() => _GameCScreenState();
}

class _GameCScreenState extends ConsumerState<GameCScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;

  // Animazione slide per la transizione foto → mappa
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startGame();
  }

  Future<void> _startGame() async {
    await ref.read(gameCProvider.notifier).initGame(
          gridRepo: ref.read(gridRepositoryProvider),
          szRepo: ref.read(safeZoneRepositoryProvider),
        );
  }

  void _onStartGuessing() {
    ref.read(gameCProvider.notifier).startGuessing();
    _slideController.forward(from: 0);
  }

  void _onMapTap(TapPosition _, LatLng latLng) {
    final phase = ref.read(gameCProvider).phase;
    if (phase != GameCPhase.guessing) return;
    ref.read(gameCProvider.notifier).updateGuess(latLng);
  }

  void _onConfirmGuess() {
    ref.read(gameCProvider.notifier).confirmGuess();
    final state = ref.read(gameCProvider);
    if (state.phase == GameCPhase.roundResult ||
        state.phase == GameCPhase.finished) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GameCRoundResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameCProvider);
    final photoProvider = ref.watch(gameCPhotoProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A14),
        body: Stack(
          children: [
            // ── Loading ─────────────────────────────────────────────────
            if (state.phase == GameCPhase.loading) _buildLoading(),
      
            // ── Fase foto ───────────────────────────────────────────────
            if (state.phase == GameCPhase.showPhoto && state.targetZone != null)
              _PhotoPhase(
                state: state,
                photoProvider: photoProvider,
                onStartGuessing: _onStartGuessing,
              ),
      
            // ── Fase guess (mappa) ───────────────────────────────────────
            if (state.phase == GameCPhase.guessing)
              SlideTransition(
                position: _slideAnimation,
                child: _GuessPhase(
                  state: state,
                  mapController: _mapController,
                  currentCamera: _currentCamera,
                  onCameraChanged: (camera) =>
                      setState(() => _currentCamera = camera),
                  onMapTap: _onMapTap,
                  onConfirm: _onConfirmGuess,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const ColoredBox(
      color: Color(0xCC000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF42A5F5)),
            SizedBox(height: 16),
            Text(
              'Caricamento...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}

// ─── Fase 1: Foto ─────────────────────────────────────────────────────────────

class _PhotoPhase extends StatelessWidget {
  final GameCState state;
  final GameCPhotoProvider photoProvider;
  final VoidCallback onStartGuessing;

  const _PhotoPhase({
    required this.state,
    required this.photoProvider,
    required this.onStartGuessing,
  });

  @override
  Widget build(BuildContext context) {
    final target = state.targetZone!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // ── HUD round ─────────────────────────────────────────────────
        _RoundHud(state: state),

        // ── Foto ──────────────────────────────────────────────────────
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto dell'area
              photoProvider.buildPhotoGallery(
                target.id,
                height: screenHeight * 0.65,
              ),

              // Gradient in fondo per leggibilità
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 160,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(217),
                      ],
                    ),
                  ),
                ),
              ),

              // Label "Indovina dove si trova"
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chip "ROUND X / Y"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withAlpha(204),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'AREA DI ATTESA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Dove si trova\nquest\'area di attesa?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bottone vai alla mappa
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onStartGuessing,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Vai alla mappa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Fase 2: Mappa guess ──────────────────────────────────────────────────────

class _GuessPhase extends StatelessWidget {
  final GameCState state;
  final MapController mapController;
  final MapCamera? currentCamera;
  final ValueChanged<MapCamera> onCameraChanged;
  final Function(TapPosition, LatLng) onMapTap;
  final VoidCallback onConfirm;

  const _GuessPhase({
    required this.state,
    required this.mapController,
    required this.currentCamera,
    required this.onCameraChanged,
    required this.onMapTap,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final hasGuess = state.guessPosition != null;

    return Stack(
      children: [
        // ── Mappa libera ──────────────────────────────────────────────
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: AppConstants.udineCenter,
            initialZoom: 13.5,
            minZoom: 10.0,
            maxZoom: 18.0,
            onTap: onMapTap,
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
            ),
            onMapEvent: (event) {
              onCameraChanged(mapController.camera);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.aree_attesa_ud',
            ),

            // Pin guess (rosso)
            if (state.guessPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: state.guessPosition!,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFEF5350),
                      size: 48,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                  ),
                ],
              ),
          ],
        ),

        // ── HUD round ────────────────────────────────────────────────
        _RoundHud(state: state),

        // ── Istruzione tap ────────────────────────────────────────────
        if (!hasGuess)
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(184),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Color(0xFF42A5F5), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tocca la mappa per piazzare il pin',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        // ── Bottone Conferma ──────────────────────────────────────────
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mostra il nome dell'area che sta cercando
              if (state.targetZone != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117).withAlpha(235),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: Color(0xFF42A5F5), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.targetZone!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // Bottone conferma
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: hasGuess ? onConfirm : null,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Conferma la mia guess'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasGuess
                        ? const Color(0xFF1565C0)
                        : Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── HUD round (condiviso tra le due fasi) ────────────────────────────────────

class _RoundHud extends StatelessWidget {
  final GameCState state;
  const _RoundHud({required this.state});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 8,
          20,
          12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117).withAlpha(235),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Round
            _HudChip(
              icon: Icons.flag_rounded,
              label: 'Round',
              value: '${state.currentRound + 1}/${state.totalRounds}',
              color: const Color(0xFF42A5F5),
            ),
            // Punteggio totale accumulato
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
