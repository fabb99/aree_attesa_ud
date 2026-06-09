import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ui/app_end_game_dialog.dart';
import '../models/game_c_state.dart';
import '../providers/game_c_provider.dart';
import '../widgets/game_c_photo_phase.dart';
import '../widgets/game_c_guess_phase.dart';
import 'game_c_round_result_screen.dart';
import 'game_c_result_screen.dart';

class GameCScreen extends ConsumerStatefulWidget {
  const GameCScreen({super.key});

  @override
  ConsumerState<GameCScreen> createState() => _GameCScreenState();
}

class _GameCScreenState extends ConsumerState<GameCScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  MapCamera? _currentCamera;

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

    Future.microtask(() => _startGame());
  }

  Future<void> _startGame() async {
    await ref.read(gameCProvider.notifier).initGame(
          gridRepo: ref.read(gridRepositoryProvider),
          szRepo: ref.read(safeZoneRepositoryProvider),
        );
  }

  Future<void> _onEndGameRequested() async {
    final confirmed = await AppEndGameDialog.show(context);
    if (confirmed && mounted) {
      ref.read(gameCProvider.notifier).endGame();
      _navigateToResults();
    }
  }

  void _navigateToResults() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameCResultScreen()),
    );
  }

  void _onStartGuessing() {
    ref.read(gameCProvider.notifier).startGuessing();
    _slideController.forward(from: 0);
  }

  void _onMapTap(TapPosition _, LatLng latLng) {
    if (ref.read(gameCProvider).phase != GameCPhase.guessing) return;
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
        backgroundColor: AppColors.bgDeep,
        body: Stack(
          children: [
            // ── Loading ─────────────────────────────────────────────
            if (state.phase == GameCPhase.loading)
              const _LoadingOverlay(),

            // ── Fase foto ───────────────────────────────────────────
            if (state.phase == GameCPhase.showPhoto &&
                state.targetZone != null)
              GameCPhotoPhase(
                state: state,
                photoProvider: photoProvider,
                onStartGuessing: _onStartGuessing,
                onEndGame: _onEndGameRequested,
              ),

            // ── Fase guess ──────────────────────────────────────────
            if (state.phase == GameCPhase.guessing)
              SlideTransition(
                position: _slideAnimation,
                child: GameCGuessPhase(
                  state: state,
                  mapController: _mapController,
                  currentCamera: _currentCamera,
                  onCameraChanged: (camera) =>
                      setState(() => _currentCamera = camera),
                  onMapTap: _onMapTap,
                  onConfirm: _onConfirmGuess,
                  onEndGame: _onEndGameRequested,
                ),
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
            CircularProgressIndicator(color: AppColors.gameCLight),
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
}