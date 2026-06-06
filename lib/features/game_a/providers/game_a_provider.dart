import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../config/game_a_config.dart';
import '../../../core/data/grid_repository.dart';
import '../../../core/data/safe_zone_repository.dart';
import '../models/game_a_state.dart';
import '../../../core/models/hex_cell.dart';
import '../services/game_a_service.dart';

// ─── Repository providers ────────────────────────────────────────────────────
//
// Definiti in core/app_providers.dart — re-export per retrocompatibilità
// con le screen che li importano da questo file.
export '../../../core/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

// ─── Game A notifier ─────────────────────────────────────────────────────────

class GameANotifier extends StateNotifier<GameAState> {
  GameANotifier() : super(GameAState.initial());

  GameAService? _service;

  /// Inizializza la partita caricando griglia e safe zone dai repository.
  Future<void> initGame({
    required GridRepository gridRepo,
    required SafeZoneRepository szRepo,
  }) async {
    state = GameAState.initial();

    try {
      final rawCells  = await gridRepo.loadGrid();
      final safeZones = await szRepo.loadSafeZones(rawCells);

      _service = GameAService();
      final cells = _service!.initializeCells(rawCells, safeZones);

      state = GameAState(
        cells:          cells,
        safeZones:      safeZones,
        movesLeft:      GameAConfig.movesPerGame,
        totalMoves:     GameAConfig.movesPerGame,
        foundSafeZones: 0,
        totalSafeZones: safeZones.length,
        phase:          GameAPhase.playing,
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('[GameA] Errore caricamento dati: $e\n$stack');
      rethrow;
    }
  }

  /// Gestisce il tap su una cella della griglia.
  ///
  /// Tutta la logica di business (mosse, conteggio, reveal finale) è delegata
  /// a [GameAService.tapCell] — il notifier si limita ad aggiornare lo state.
  /// Se il gioco è già terminato, permette solo di riaprire il banner
  /// informativo sulle safe zone già visibili.
  void tapCell(int cellId) {
    final cell = state.cells.firstWhere(
      (c) => c.id == cellId,
      orElse: () => throw StateError('Cell $cellId not found'),
    );

    // Gioco terminato: mostra solo il banner informativo
    if (state.phase != GameAPhase.playing) {
      if (cell.isSafeZone) {
        state = state.copyWith(
          lastFoundName:    cell.safeZoneName,
          lastFoundAddress: cell.safeZoneAddress,
        );
      }
      return;
    }

    final result = _service!.tapCell(
      cells:          state.cells,
      cellId:         cellId,
      movesLeft:      state.movesLeft,
      foundSafeZones: state.foundSafeZones,
    );

    state = state.copyWith(
      cells:            result.cells,
      movesLeft:        result.movesLeft,
      foundSafeZones:   result.foundSafeZones,
      phase:            result.isFinished ? GameAPhase.finished : GameAPhase.playing,
      lastFoundName:    result.foundSafeZone ? cell.safeZoneName    : null,
      lastFoundAddress: result.foundSafeZone ? cell.safeZoneAddress : null,
    );
  }

  /// Termina la partita anticipatamente su richiesta dell'utente.
  ///
  /// Rivela tutte le safe zone ancora nascoste, esattamente come
  /// avviene quando le mosse si esauriscono naturalmente.
  void endGame() {
    if (state.phase != GameAPhase.playing) return;

    final finalCells = state.cells.map((c) {
      if (c.isSafeZone && c.state == CellState.hidden) {
        return c.copyWith(state: CellState.revealed);
      }
      return c;
    }).toList();

    state = state.copyWith(
      cells:          finalCells,
      phase:          GameAPhase.finished,
      clearLastFound: true,
    );
  }

  /// Nasconde il banner dell'ultima safe zone trovata.
  void clearLastFound() {
    state = state.copyWith(clearLastFound: true);
  }

  /// Restituisce l'id della cella che contiene [point], o null se fuori griglia.
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