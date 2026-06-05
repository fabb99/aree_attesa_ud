import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/data/grid_repository.dart';
import '../../../core/data/safe_zone_repository.dart';
import '../../../core/models/safe_zone.dart';
import '../config/game_b_config.dart';
import '../models/game_b_state.dart';
import '../services/game_b_service.dart';

// ─── Repository providers ────────────────────────────────────────────────────
//
// RIMOSSI da qui: vivono esclusivamente in core/app_providers.dart.
// Re-export per retrocompatibilità con le screen che li importano da questo file.
export '../../../core/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

// ─── Game B notifier ─────────────────────────────────────────────────────────

class GameBNotifier extends StateNotifier<GameBState> {
  GameBNotifier() : super(GameBState.initial());

  final GameBService _service = GameBService();

  /// Lista dei target pre-estratti per tutta la partita.
  /// Privata: la UI non deve accedervi direttamente.
  List<_RoundTarget> _roundTargets = [];

  /// Inizializza la partita caricando griglia, safe zone e target dei round.
  Future<void> initGame({
    required GridRepository gridRepo,
    required SafeZoneRepository szRepo,
  }) async {
    state = GameBState.initial();

    try {
      final rawCells = await gridRepo.loadGrid();
      final safeZones = await szRepo.loadSafeZones(rawCells);
      final cells = _service.initializeCells(rawCells, safeZones);

      // Pre-estrae i target per tutti i round in modo casuale senza ripetizioni
      final targets = _service.pickRoundTargets(safeZones, GameBConfig.roundsPerGame);
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
      // ignore: avoid_print
      print('[GameB] Errore caricamento: $e\n$stack');
      rethrow;
    }
  }

  /// Gestisce il tap su una cella della griglia.
  ///
  /// Tap corretto → salva il round e passa a [GameBPhase.roundResult].
  /// Tap sbagliato → rivela la cella con la distanza dal target.
  void tapCell(int cellId) {
    if (state.phase != GameBPhase.playing) return;

    final targetCellId = _roundTargets[state.currentRound].cellId;

    final result = _service.tapCell(
      cells: state.cells,
      tappedCellId: cellId,
      targetCellId: targetCellId,
    );

    if (result.isCorrect) {
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
      // Tap sbagliato: aggiorna celle e incrementa i tentativi
      final newWrongTaps = state.wrongTaps + 1;
      final newRoundScore = _service.calculateRoundScore(newWrongTaps);

      state = state.copyWith(
        cells: result.cells,
        wrongTaps: newWrongTaps,
        currentRoundScore: newRoundScore,
      );
    }
  }

  /// Avanza al round successivo dopo la schermata di risultato intermedio.
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

  /// Restituisce l'id della cella che contiene [point], o null se fuori griglia.
  int? findCellAtPoint(LatLng point) {
    for (final cell in state.cells) {
      if (cell.containsPoint(point)) return cell.id;
    }
    return null;
  }

  void endGame() {
    if (state.phase != GameBPhase.playing) return;
    state = state.copyWith(phase: GameBPhase.finished);
  }
}

// ─── Struttura interna ────────────────────────────────────────────────────────

/// Associa una [SafeZone] al suo [cellId] per uso interno al notifier.
/// Non esposta all'esterno del file.
class _RoundTarget {
  final SafeZone safeZone;
  final int cellId;

  const _RoundTarget({required this.safeZone, required this.cellId});
}

// ─── Provider ────────────────────────────────────────────────────────────────

final gameBProvider =
    StateNotifierProvider.autoDispose<GameBNotifier, GameBState>(
        (ref) => GameBNotifier());