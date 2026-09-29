import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../config/game_a_config.dart';
import '../../../core/data/grid_repository.dart';
import '../../../core/data/safe_zone_repository.dart';
import '../models/game_a_state.dart';
import '../../../core/models/hex_cell.dart';
import '../services/game_a_service.dart';

export '../../../core/providers/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

// ─── Game A notifier ─────────────────────────────────────────────────────────

class GameANotifier extends StateNotifier<GameAState> {
  GameANotifier() : super(GameAState.initial());

  GameAService? _service;

  Future<void> initGame({
    required GridRepository gridRepo,
    required SafeZoneRepository szRepo,
  }) async {
    state = GameAState.initial();

    try {
      final rawCells = await gridRepo.loadGrid();
      final safeZones = await szRepo.loadSafeZones(rawCells);

      _service = GameAService();
      final cells = _service!.initializeCells(rawCells, safeZones);

      state = GameAState(
        cells: cells,
        safeZones: safeZones,
        movesLeft: GameAConfig.movesPerGame,
        totalMoves: GameAConfig.movesPerGame,
        foundSafeZones: 0,
        totalSafeZones: safeZones.length,
        phase: GameAPhase.playing,
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('[GameA] Errore caricamento dati: $e\n$stack');
      rethrow;
    }
  }

  void tapCell(int cellId) {
    final cell = state.cells.firstWhere(
      (c) => c.id == cellId,
      orElse: () => throw StateError('Cell $cellId not found'),
    );

    // Gioco terminato: mostra solo il banner informativo
    if (state.phase != GameAPhase.playing) {
      if (cell.isSafeZone) {
        state = state.copyWith(
          lastFoundName: cell.safeZoneName,
          lastFoundAddress: cell.safeZoneAddress,
        );
      }
      return;
    }

    final result = _service!.tapCell(
      cells: state.cells,
      cellId: cellId,
      movesLeft: state.movesLeft,
      foundSafeZones: state.foundSafeZones,
    );

    // ── Logica tip ────────────────────────────────────────────────────────────
    // Una mossa "sbagliata" è un tap su cella normale (non safe zone) che
    // produce un cambiamento di stato (non un no-op su cella già rivelata).
    // result.foundSafeZone == false E result.movesLeft < state.movesLeft
    // significa che è stata consumata una mossa su cella normale.
    final isWrongTap = !result.foundSafeZone &&
        result.movesLeft < state.movesLeft; // mossa consumata, non safe zone

    int newWrongTaps = state.wrongTapsSinceLastTip;
    bool shouldShowTip = false;

    if (isWrongTap) {
      newWrongTaps += 1;
      if (newWrongTaps >= GameAConfig.wrongTapsPerTip) {
        shouldShowTip = true;
        newWrongTaps = 0; // reset contatore
      }
    } else if (result.foundSafeZone) {
      // Trovata una safe zone: reset del contatore (le mosse "buone" non
      // devono accumulare verso la prossima tip — logica "non consecutive")
      newWrongTaps = 0;
    }
    // ─────────────────────────────────────────────────────────────────────────

    state = state.copyWith(
      cells: result.cells,
      movesLeft: result.movesLeft,
      foundSafeZones: result.foundSafeZones,
      phase: result.isFinished ? GameAPhase.finished : GameAPhase.playing,
      lastFoundName: result.foundSafeZone ? cell.safeZoneName : null,
      lastFoundAddress: result.foundSafeZone ? cell.safeZoneAddress : null,
      wrongTapsSinceLastTip: newWrongTaps,
      showTip: shouldShowTip,
    );
  }

  /// Chiamato dalla screen dopo aver mostrato la tip, per abbassare il flag.
  void clearShowTip() {
    state = state.copyWith(showTip: false);
  }

  void endGame() {
    if (state.phase != GameAPhase.playing) return;

    final finalCells = state.cells.map((c) {
      if (c.isSafeZone && c.state == CellState.hidden) {
        return c.copyWith(state: CellState.revealed);
      }
      return c;
    }).toList();

    state = state.copyWith(
      cells: finalCells,
      phase: GameAPhase.finished,
      clearLastFound: true,
    );
  }

  void clearLastFound() {
    state = state.copyWith(clearLastFound: true);
  }

  int? findCellAtPoint(LatLng point) {
    for (final cell in state.cells) {
      if (cell.containsPoint(point)) return cell.id;
    }
    return null;
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final gameAProvider =
    StateNotifierProvider.autoDispose<GameANotifier, GameAState>(
        (ref) => GameANotifier());