import 'dart:collection';
import '../../../core/models/hex_cell.dart';
import '../../../core/models/safe_zone.dart';

/// Logica pura del Gioco A: inizializzazione griglia, BFS distanze, gestione tap.
///
/// Questa classe non dipende da Flutter né da Riverpod — è testabile in isolamento.
class GameAService {

  // ── Inizializzazione ──────────────────────────────────────────────────────

  /// Prepara la lista iniziale di celle con distanze e flag safe zone.
  ///
  /// Esegue un BFS multi-sorgente da tutte le safe zone contemporaneamente
  /// per calcolare la distanza minima di ogni cella in O(N) invece di
  /// eseguire un BFS separato per ogni safe zone.
  /// Tutte le celle partono in stato [CellState.hidden].
  List<HexCell> initializeCells(
    List<HexCell> rawCells,
    List<SafeZone> safeZones,
  ) {
    final idToIndex = <int, int>{
      for (int i = 0; i < rawCells.length; i++) rawCells[i].id: i,
    };

    final safeZoneCellIds = {for (final sz in safeZones) sz.cellId};
    final safeZoneByCell  = {for (final sz in safeZones) sz.cellId: sz};

    // BFS multi-sorgente: distanza minima da qualsiasi safe zone
    final distances = List<int>.filled(rawCells.length, _infinity);
    final queue = Queue<int>();

    for (final cellId in safeZoneCellIds) {
      final idx = idToIndex[cellId];
      if (idx != null) {
        distances[idx] = 0;
        queue.add(cellId);
      }
    }

    while (queue.isNotEmpty) {
      final currentId  = queue.removeFirst();
      final currentIdx = idToIndex[currentId]!;
      final nextDist   = distances[currentIdx] + 1;

      for (final neighborId in rawCells[currentIdx].neighbors) {
        final neighborIdx = idToIndex[neighborId];
        if (neighborIdx == null) continue;
        if (distances[neighborIdx] > nextDist) {
          distances[neighborIdx] = nextDist;
          queue.add(neighborId);
        }
      }
    }

    // Conta le safe zone adiacenti (distanza 1) per ogni cella
    final adjacentCounts = List<int>.filled(rawCells.length, 0);
    for (int i = 0; i < rawCells.length; i++) {
      adjacentCounts[i] = rawCells[i].neighbors
          .where(safeZoneCellIds.contains)
          .length;
    }

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

  // ── Tap ───────────────────────────────────────────────────────────────────

  /// Gestisce il tap su una cella e restituisce il nuovo stato completo.
  ///
  /// Responsabilità di questo metodo (logica di business, non UI):
  /// - Cambiare lo stato della cella toccata (hidden → revealed/found)
  /// - Calcolare il numero di mosse rimanenti
  /// - Contare le safe zone trovate
  /// - Rivelare le safe zone rimanenti se le mosse si esauriscono
  ///
  /// Il notifier si limita a leggere [TapResult] e aggiornare lo state.
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

    // Tap su cella già rivelata (non safe zone): no-op
    if (cell.state != CellState.hidden && !cell.isSafeZone) {
      return TapResult.noOp(cells: cells, movesLeft: movesLeft, foundSafeZones: foundSafeZones);
    }

    // Tap su safe zone già trovata: no-op (ma la UI può mostrare il banner)
    if (cell.state == CellState.found) {
      return TapResult.noOp(cells: cells, movesLeft: movesLeft, foundSafeZones: foundSafeZones);
    }

    final newCellState   = cell.isSafeZone ? CellState.found : CellState.revealed;
    final foundSafeZone  = cell.isSafeZone;
    final newMovesLeft   = movesLeft - 1;
    final newFoundCount  = foundSafeZones + (foundSafeZone ? 1 : 0);
    final isFinished     = newMovesLeft <= 0;

    var updatedCells = List<HexCell>.from(cells);
    updatedCells[idx] = cell.copyWith(state: newCellState);

    // Se le mosse sono esaurite, rivela tutte le safe zone ancora nascoste
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

  // ── Costanti private ──────────────────────────────────────────────────────

  static const int _infinity = 9999;
}

// ── Result object ─────────────────────────────────────────────────────────────

/// Risultato di un tap su una cella nel Gioco A.
///
/// Usare un oggetto dedicato invece di un record anonimo rende
/// il codice più leggibile e il contratto del metodo esplicito.
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

  /// Costruttore per il caso in cui il tap non produce nessun cambiamento.
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
