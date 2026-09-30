import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/data/grid_repository.dart';
import '../../../core/data/safe_zone_repository.dart';
import '../config/game_a_config.dart';
import '../models/game_a_state.dart';
import '../../../core/models/hex_cell.dart';
import '../services/game_a_service.dart';

// Esportiamo i provider di base per comodità di importazione nelle schermate.
export '../../../core/providers/app_providers.dart'
    show gridRepositoryProvider, safeZoneRepositoryProvider;

/// Gestore dello stato (Notifier) per il Gioco A.
///
/// Funge da Controller nell'architettura MVC/MVVM:
/// - Riceve gli input dalla UI (es. [tapCell]).
/// - Delega i calcoli complessi al [GameAService].
/// - Aggiorna lo stato immutabile, notificando la UI per il rebuild.
class GameANotifier extends StateNotifier<GameAState> {
  GameANotifier() : super(GameAState.initial());

  GameAService? _service;

  /// Inizializza la partita caricando la griglia e calcolando le distanze BFS.
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
      debugPrint('[GameA] Errore caricamento dati: $e\n$stack');
      rethrow;
    }
  }

  /// Gestisce il tocco dell'utente su un esagono della mappa.
  void tapCell(int cellId) {
    final cell = state.cells.firstWhere(
      (c) => c.id == cellId,
      orElse: () => throw StateError('Cella $cellId non trovata'),
    );

    // Se il gioco è finito, permette solo di visualizzare i banner informativi
    if (state.phase != GameAPhase.playing) {
      if (cell.isSafeZone) {
        state = state.copyWith(
          lastFoundName: cell.safeZoneName,
          lastFoundAddress: cell.safeZoneAddress,
        );
      }
      return;
    }

    // Delega la logica di business al Service
    final result = _service!.tapCell(
      cells: state.cells,
      cellId: cellId,
      movesLeft: state.movesLeft,
      foundSafeZones: state.foundSafeZones,
    );

    // ── Logica Suggerimenti (Tips) ──────────────────────────────────────────
    // Consideriamo "sbagliato" un tap che consuma una mossa ma non trova un'area.
    final isWrongTap = !result.foundSafeZone && result.movesLeft < state.movesLeft; 

    int newWrongTaps = state.wrongTapsSinceLastTip;
    bool shouldShowTip = false;

    if (isWrongTap) {
      newWrongTaps += 1;
      // Mostra un suggerimento se l'utente sbaglia ripetutamente
      if (newWrongTaps >= GameAConfig.wrongTapsPerTip) {
        shouldShowTip = true;
        newWrongTaps = 0; // Reset contatore
      }
    } else if (result.foundSafeZone) {
      // Un successo resetta la frustrazione dell'utente, quindi azzeriamo i tap sbagliati
      newWrongTaps = 0;
    }
    // ────────────────────────────────────────────────────────────────────────

    // Aggiornamento finale dello stato
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

  /// Disattiva il flag per la visualizzazione della tip (chiamato dalla UI dopo il render).
  void clearShowTip() {
    state = state.copyWith(showTip: false);
  }

  /// Forza la conclusione della partita, rivelando le aree non trovate.
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

  /// Chiude il banner dell'ultima area trovata.
  void clearLastFound() {
    state = state.copyWith(clearLastFound: true);
  }

  /// Risolve una coordinata geografica nell'ID della cella corrispondente.
  int? findCellAtPoint(LatLng point) {
    for (final cell in state.cells) {
      if (cell.containsPoint(point)) return cell.id;
    }
    return null;
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

/// Provider `autoDispose` per garantire la pulizia della memoria:
/// Quando l'utente esce dalla schermata, lo stato si resetta automaticamente.
final gameAProvider =
    StateNotifierProvider.autoDispose<GameANotifier, GameAState>(
        (ref) => GameANotifier());