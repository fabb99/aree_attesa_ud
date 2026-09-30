import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; 
import 'package:latlong2/latlong.dart';
import '../../../../core/data/grid_repository.dart';
import '../../../../core/data/safe_zone_repository.dart';
import '../../../../core/models/safe_zone.dart';
import '../config/game_b_config.dart';
import '../models/game_b_state.dart';
import '../services/game_b_service.dart';

export '../../../core/providers/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

// ─── Struttura interna ────────────────────────────────────────────────────────

/// Rappresentazione interna del target corrente (SafeZone + ID della cella in mappa).
class _RoundTarget {
  final SafeZone safeZone;
  final int cellId;

  const _RoundTarget({required this.safeZone, required this.cellId});
}

// ─── Game B Notifier ─────────────────────────────────────────────────────────

/// Gestore dello stato per il Gioco B.
class GameBNotifier extends StateNotifier<GameBState> {
  GameBNotifier() : super(GameBState.initial());

  final GameBService _service = GameBService();
  List<_RoundTarget> _roundTargets = [];

  /// Contatore dei tap sbagliati (errori cumulativi sull'intera partita).
  ///
  /// Mantenuto all'interno del Notifier e non in `GameBState` poiché è logica 
  /// interna (serve solo per determinare *quando* alzare la notifica di un Tip)
  /// e non un dato che la UI deve renderizzare direttamente.
  int _wrongTapsSinceLastTip = 0;

  /// Inizializza la partita (carica i dati, estrae i target, prepara il Round 1).
  Future<void> initGame({
    required GridRepository gridRepo,
    required SafeZoneRepository szRepo,
  }) async {
    state = GameBState.initial();
    _wrongTapsSinceLastTip = 0;

    try {
      final rawCells = await gridRepo.loadGrid();
      final safeZones = await szRepo.loadSafeZones(rawCells);
      final cells = _service.initializeCells(rawCells, safeZones);

      final targets =
          _service.pickRoundTargets(safeZones, GameBConfig.roundsPerGame);
      _roundTargets = targets
          .map((sz) => _RoundTarget(safeZone: sz, cellId: sz.cellId))
          .toList();

      state = GameBState(
        cells: cells,
        safeZones: safeZones,
        currentRound: 0,
        totalRounds: GameBConfig.roundsPerGame,
        targetZone: _roundTargets[0].safeZone,
        wrongTaps: 0,
        currentRoundScore: GameBConfig.maxScorePerRound,
        completedRounds: [],
        phase: GameBPhase.playing,
      );
    } catch (e, stack) {
      debugPrint('[GameB] Errore caricamento: $e\n$stack');
      rethrow;
    }
  }

  /// Gestisce il tap su una cella durante la fase di gioco.
  ///
  /// Ritorna `true` se la UI deve attivare e mostrare un suggerimento educativo.
  bool tapCell(int cellId) {
    if (state.phase != GameBPhase.playing) return false;

    final targetCellId = _roundTargets[state.currentRound].cellId;

    final result = _service.tapCell(
      cells: state.cells,
      tappedCellId: cellId,
      targetCellId: targetCellId,
    );

    bool shouldShowTip = false;

    if (result.isCorrect) {
      // ── CASO A: L'utente ha indovinato ──
      final roundScore = _service.calculateRoundScore(state.wrongTaps);
      final completedRound = RoundResult(
        targetZone: _roundTargets[state.currentRound].safeZone,
        tapsUsed: state.wrongTaps + 1,
        score: roundScore,
      );

      final isLastRound = state.currentRound >= state.totalRounds - 1;

      state = state.copyWith(
        cells: result.cells,
        completedRounds: [...state.completedRounds, completedRound],
        currentRoundScore: roundScore,
        phase: isLastRound ? GameBPhase.finished : GameBPhase.roundResult,
      );
    } else {
      // ── CASO B: L'utente ha sbagliato ──
      _wrongTapsSinceLastTip += 1;
      
      // Controllo per il trigger dei suggerimenti (Tips)
      if (_wrongTapsSinceLastTip >= GameBConfig.wrongTapsPerTip) {
        shouldShowTip = true;
        _wrongTapsSinceLastTip = 0; // Reset
      }

      final newWrongTaps = state.wrongTaps + 1;
      final newRoundScore = _service.calculateRoundScore(newWrongTaps);

      state = state.copyWith(
        cells: result.cells,
        wrongTaps: newWrongTaps,
        currentRoundScore: newRoundScore,
      );
    }

    return shouldShowTip;
  }

  /// Passa al round successivo ripristinando la mappa e i punteggi.
  void nextRound() {
    if (state.phase != GameBPhase.roundResult) return;

    final nextRoundIndex = state.currentRound + 1;
    final resetCells = _service.resetCellsForNewRound(state.cells);

    state = state.copyWith(
      cells: resetCells,
      currentRound: nextRoundIndex,
      targetZone: _roundTargets[nextRoundIndex].safeZone,
      wrongTaps: 0,
      currentRoundScore: GameBConfig.maxScorePerRound,
      phase: GameBPhase.playing,
    );
  }

  /// Cerca quale cella corrisponde a un punto specifico (usato dal tap mappa).
  int? findCellAtPoint(LatLng point) {
    for (final cell in state.cells) {
      if (cell.containsPoint(point)) return cell.id;
    }
    return null;
  }

  /// Forza la fine anticipata del gioco.
  void endGame() {
    if (state.phase != GameBPhase.playing) return;
    state = state.copyWith(phase: GameBPhase.finished);
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final gameBProvider =
    StateNotifierProvider.autoDispose<GameBNotifier, GameBState>(
        (ref) => GameBNotifier());