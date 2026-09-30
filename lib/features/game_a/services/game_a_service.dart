import 'dart:collection';
import '../../../core/models/hex_cell.dart';
import '../../../core/models/safe_zone.dart';

/// Logica pura (Business Logic) del Gioco A.
class GameAService {
  static const int _infinity = 9999;

  // ── Inizializzazione ──────────────────────────────────────────────────────

  /// Prepara la lista iniziale di celle popolando distanze e attributi.
  ///
  /// **Algoritmo**: Esegue una **Breadth-First Search (BFS) multi-sorgente** 
  /// partendo simultaneamente da tutte le Safe Zone. Questo calcola la distanza 
  /// minima di ogni cella in O(V+E), risultando estremamente più performante 
  /// rispetto all'esecuzione di una BFS separata per ogni singola area.
  List<HexCell> initializeCells(
    List<HexCell> rawCells,
    List<SafeZone> safeZones,
  ) {
    // Mappa per un accesso rapido O(1) agli indici delle celle
    final idToIndex = <int, int>{
      for (int i = 0; i < rawCells.length; i++) rawCells[i].id: i,
    };

    final safeZoneCellIds = {for (final sz in safeZones) sz.cellId};
    final safeZoneByCell  = {for (final sz in safeZones) sz.cellId: sz};

    // BFS Multi-sorgente
    final distances = List<int>.filled(rawCells.length, _infinity);
    final queue = Queue<int>();

    // 1. Inserisce in coda tutte le "sorgenti" (le aree di attesa) a distanza 0
    for (final cellId in safeZoneCellIds) {
      final idx = idToIndex[cellId];
      if (idx != null) {
        distances[idx] = 0;
        queue.add(cellId);
      }
    }

    // 2. Espansione dell'onda BFS
    while (queue.isNotEmpty) {
      final currentId  = queue.removeFirst();
      final currentIdx = idToIndex[currentId]!;
      final nextDist   = distances[currentIdx] + 1;

      for (final neighborId in rawCells[currentIdx].neighbors) {
        final neighborIdx = idToIndex[neighborId];
        if (neighborIdx == null) continue;
        
        // Se troviamo un percorso più breve, aggiorniamo e accodiamo
        if (distances[neighborIdx] > nextDist) {
          distances[neighborIdx] = nextDist;
          queue.add(neighborId);
        }
      }
    }

    // Conta le safe zone adiacenti (distanza 1) per ogni cella (Meccanica in stile Campo Minato)
    final adjacentCounts = List<int>.filled(rawCells.length, 0);
    for (int i = 0; i < rawCells.length; i++) {
      adjacentCounts[i] = rawCells[i].neighbors
          .where(safeZoneCellIds.contains)
          .length;
    }

    // Genera l'array finale di celle valorizzate
    return [
      for (int i = 0; i < rawCells.length; i++)
        rawCells[i].copyWith(
          distanceToNearest: distances[i] == _infinity ? null : distances[i],
          adjacentSafeZones: adjacentCounts[i],
          isSafeZone:        safeZoneCellIds.contains(rawCells[i].id),
          safeZoneName:      safeZoneByCell[rawCells[i].id]?.name,
          safeZoneAddress:   safeZoneByCell[rawCells[i].id]?.address,
          state:             CellState.hidden,
        ),
    ];
  }

  // ── Gestione Interazione (Tap) ────────────────────────────────────────────

  /// Calcola il risultato di un tap su una cella.
  ///
  /// Restituisce un oggetto tipizzato [TapResult] contenente lo stato aggiornato.
  TapResult tapCell({
    required List<HexCell> cells,
    required int cellId,
    required int movesLeft,
    required int foundSafeZones,
  }) {
    final idx = cells.indexWhere((c) => c.id == cellId);
    if (idx == -1) {
      return TapResult.noOp(cells: cells, movesLeft: movesLeft, foundSafeZones: foundSafeZones);
    }

    final cell = cells[idx];

    // Se la cella è già rivelata e NON è una safe zone, non fa nulla
    if (cell.state != CellState.hidden && !cell.isSafeZone) {
      return TapResult.noOp(cells: cells, movesLeft: movesLeft, foundSafeZones: foundSafeZones);
    }

    // Se è una safe zone già trovata, non scala mosse
    if (cell.state == CellState.found) {
      return TapResult.noOp(cells: cells, movesLeft: movesLeft, foundSafeZones: foundSafeZones);
    }

    // Calcolo del nuovo stato
    final newCellState   = cell.isSafeZone ? CellState.found : CellState.revealed;
    final foundSafeZone  = cell.isSafeZone;
    final newMovesLeft   = movesLeft - 1;
    final newFoundCount  = foundSafeZones + (foundSafeZone ? 1 : 0);
    final isFinished     = newMovesLeft <= 0;

    var updatedCells = List<HexCell>.from(cells);
    updatedCells[idx] = cell.copyWith(state: newCellState);

    // Se il gioco finisce (mosse esaurite), rivela le aree non trovate (game over)
    if (isFinished) {
      updatedCells = updatedCells.map((c) {
        if (c.isSafeZone && c.state == CellState.hidden) {
          return c.copyWith(state: CellState.revealed);
        }
        return c;
      }).toList();
    }

    return TapResult(
      cells:           updatedCells,
      movesLeft:       newMovesLeft,
      foundSafeZones:  newFoundCount,
      foundSafeZone:   foundSafeZone,
      isFinished:      isFinished,
    );
  }
}

// ── Oggetti di Ritorno ────────────────────────────────────────────────────────

/// Struttura dati (Data Transfer Object) che incapsula il risultato di una mossa.
/// 
/// Utilizzare una classe esplicita invece di tuple o record rende il codice
/// molto più leggibile e il contratto del metodo esplicito e sicuro.
class TapResult {
  final List<HexCell> cells;
  final int movesLeft;
  final int foundSafeZones;
  final bool foundSafeZone;
  final bool isFinished;

  const TapResult({
    required this.cells,
    required this.movesLeft,
    required this.foundSafeZones,
    required this.foundSafeZone,
    required this.isFinished,
  });

  /// Costruttore di convenienza per mosse nulle (no-op).
  factory TapResult.noOp({
    required List<HexCell> cells,
    required int movesLeft,
    required int foundSafeZones,
  }) => TapResult(
        cells:          cells,
        movesLeft:      movesLeft,
        foundSafeZones: foundSafeZones,
        foundSafeZone:  false,
        isFinished:     false,
      );
}