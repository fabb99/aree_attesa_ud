import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
//import '../../../core/app_providers.dart';
import '../../../../core/data/grid_repository.dart';
import '../../../../core/data/safe_zone_repository.dart';
import '../../../../core/models/safe_zone.dart';
import '../config/game_c_config.dart';
import '../models/game_c_state.dart';
import '../services/game_c_service.dart';
import '../photo/game_c_photo_provider.dart';

// ─── Repository providers ────────────────────────────────────────────────────
//
// Definiti in core/app_providers.dart — re-export per retrocompatibilità
// con le screen che li importano da questo file.
export '../../../../core/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

// ─── Photo provider ───────────────────────────────────────────────────────────


final gameCPhotoProvider = Provider<GameCPhotoProvider>(
  (_) => const AssetPhotoProvider(),
);

// ─── Game C notifier ──────────────────────────────────────────────────────────

class GameCNotifier extends StateNotifier<GameCState> {
  GameCNotifier() : super(GameCState.initial());

  final GameCService _service = GameCService();
  List<SafeZone> _roundTargets = [];

  /// Inizializza la partita caricando griglia, safe zone e target dei round.
  Future<void> initGame({
    required GridRepository gridRepo,
    required SafeZoneRepository szRepo,
  }) async {
    state = GameCState.initial();

    try {
      final rawCells = await gridRepo.loadGrid();
      final safeZones = await szRepo.loadSafeZones(rawCells);

      _roundTargets = _service.pickRoundTargets(
        safeZones,
        GameCConfig.roundsPerGame,
      );

      state = GameCState(
        safeZones: safeZones,
        currentRound: 0,
        totalRounds: GameCConfig.roundsPerGame,
        targetZone: _roundTargets[0],
        completedRounds: [],
        phase: GameCPhase.showPhoto,
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('[GameC] Errore caricamento: $e\n$stack');
      rethrow;
    }
  }

  /// Avanza dalla fase [GameCPhase.showPhoto] alla fase [GameCPhase.guessing].
  void startGuessing() {
    if (state.phase != GameCPhase.showPhoto) return;
    state = state.copyWith(phase: GameCPhase.guessing, clearGuess: true);
  }

  /// Aggiorna la posizione del pin sulla mappa durante la fase di guess.
  void updateGuess(LatLng position) {
    if (state.phase != GameCPhase.guessing) return;
    state = state.copyWith(guessPosition: position);
  }

  /// Conferma la guess corrente, calcola distanza e punteggio e salva il round.
  void confirmGuess() {
    if (state.phase != GameCPhase.guessing) return;
    if (state.guessPosition == null || state.targetZone == null) return;

    final distMeters = _service.distanceMeters(
      state.guessPosition!,
      state.targetZone!.position,
    );
    final score = _service.calculateScore(distMeters);

    final result = GameCRoundResult(
      targetZone: state.targetZone!,
      guessPosition: state.guessPosition!,
      distanceMeters: distMeters,
      score: score,
    );

    final isLastRound = state.currentRound >= state.totalRounds - 1;

    state = state.copyWith(
      completedRounds: [...state.completedRounds, result],
      phase: isLastRound ? GameCPhase.finished : GameCPhase.roundResult,
    );
  }

  /// Avanza al round successivo dopo la schermata di risultato intermedio.
  void nextRound() {
    if (state.phase != GameCPhase.roundResult) return;
    final nextIndex = state.currentRound + 1;
    state = state.copyWith(
      currentRound: nextIndex,
      targetZone: _roundTargets[nextIndex],
      clearGuess: true,
      phase: GameCPhase.showPhoto,
    );
  }

  void endGame() {
    if (state.phase != GameCPhase.guessing &&
        state.phase != GameCPhase.showPhoto) return;
    state = state.copyWith(phase: GameCPhase.finished);
  }

  GameCService get service => _service;
}

// ─── Provider ────────────────────────────────────────────────────────────────

final gameCProvider =
    StateNotifierProvider.autoDispose<GameCNotifier, GameCState>(
        (ref) => GameCNotifier());