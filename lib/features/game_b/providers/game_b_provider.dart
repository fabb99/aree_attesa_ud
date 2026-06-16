import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/data/grid_repository.dart';
import '../../../../core/data/safe_zone_repository.dart';
import '../../../../core/models/safe_zone.dart';
import '../config/game_b_config.dart';
import '../models/game_b_state.dart';
import '../services/game_b_service.dart';

export '../../../core/priveders/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

// ─── Game B notifier ─────────────────────────────────────────────────────────

class GameBNotifier extends StateNotifier<GameBState> {
  GameBNotifier() : super(GameBState.initial());

  final GameBService _service = GameBService();
  List<_RoundTarget> _roundTargets = [];

  /// Contatore wrongTap cumulativi dall'ultima tip mostrata.
  /// Vive nel notifier (non nello state) perché è logica interna,
  /// non serve alla UI per renderizzare nulla.
  int _wrongTapsSinceLastTip = 0;

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
      // ignore: avoid_print
      print('[GameB] Errore caricamento: $e\n$stack');
      rethrow;
    }
  }

  /// Gestisce il tap su una cella.
  ///
  /// Restituisce `true` se va mostrata una tip dopo questo tap.
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
      // ── Logica tip ──────────────────────────────────────────────────────────
      // wrongTaps è per-round (resettato a 0 ogni nextRound).
      // _wrongTapsSinceLastTip è cumulativo su tutta la partita.
      _wrongTapsSinceLastTip += 1;
      if (_wrongTapsSinceLastTip >= GameBConfig.wrongTapsPerTip) {
        shouldShowTip = true;
        _wrongTapsSinceLastTip = 0; // reset
      }
      // ───────────────────────────────────────────────────────────────────────

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

class _RoundTarget {
  final SafeZone safeZone;
  final int cellId;

  const _RoundTarget({required this.safeZone, required this.cellId});
}

// ─── Provider ────────────────────────────────────────────────────────────────

final gameBProvider =
    StateNotifierProvider.autoDispose<GameBNotifier, GameBState>(
        (ref) => GameBNotifier());