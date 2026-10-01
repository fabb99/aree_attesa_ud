import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/data/grid_repository.dart';
import '../../../../core/data/safe_zone_repository.dart';
import '../../../../core/models/safe_zone.dart';
import '../config/game_c_config.dart';
import '../models/game_c_state.dart';
import '../services/game_c_service.dart';
import '../photo/game_c_photo_provider.dart';

// Esporta i repository core per facilitare l'importazione dalle schermate.
export '../../../core/providers/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

// ─── Photo Provider ─────────────────────────────────────────────────────────

/// Fornisce l'implementazione concreta per il caricamento delle fotografie.
final gameCPhotoProvider = Provider<GameCPhotoProvider>(
  (_) => const AssetPhotoProvider(),
);

// ─── Game C Notifier ────────────────────────────────────────────────────────

/// Gestore di stato per il Gioco C (GeoGuesser).
class GameCNotifier extends StateNotifier<GameCState> {
  GameCNotifier() : super(GameCState.initial());

  final GameCService _service = GameCService();
  List<SafeZone> _roundTargets = [];

  /// Inizializza la partita caricando le aree di attesa e selezionando i target.
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
        phase: GameCPhase.showPhoto, // Parte mostrando la foto del primo round
      );
    } catch (e, stack) {
      debugPrint('[GameC] Errore caricamento: $e\n$stack');
      rethrow;
    }
  }

  /// Transita dalla fase di osservazione della foto a quella della mappa.
  void startGuessing() {
    if (state.phase != GameCPhase.showPhoto) return;
    state = state.copyWith(phase: GameCPhase.guessing, clearGuess: true);
  }

  /// Aggiorna la posizione del pin trascinato o tappato sulla mappa.
  void updateGuess(LatLng position) {
    if (state.phase != GameCPhase.guessing) return;
    state = state.copyWith(guessPosition: position);
  }

  /// Conferma la guess corrente, calcola il punteggio tramite il Service e salva il round.
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

  /// Avanza al round successivo dopo la schermata dei risultati intermedi.
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

  /// Forza la fine anticipata del gioco.
  void endGame() {
    if (state.phase != GameCPhase.guessing &&
        state.phase != GameCPhase.showPhoto) {
      return;
    }
    state = state.copyWith(phase: GameCPhase.finished);
  }

  /// Rende disponibile il Service per accedere alle utility di formattazione dalla UI.
  GameCService get service => _service;
}

// ─── Provider ────────────────────────────────────────────────────────────────

final gameCProvider =
    StateNotifierProvider.autoDispose<GameCNotifier, GameCState>(
        (ref) => GameCNotifier());