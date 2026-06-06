import 'dart:collection';
import '../../../../core/models/hex_cell.dart';
import '../../../../core/models/safe_zone.dart';
import '../config/game_b_config.dart';
 
class GameBService {
  /// Calcola la distanza in celle tra due celle tramite BFS sul grafo di adiacenza.
  int cellDistance(List<HexCell> cells, int fromId, int toId) {
    if (fromId == toId) return 0;
 
    final idToCell = {for (final c in cells) c.id: c};
    final visited = <int>{fromId};
    final queue = Queue<(int, int)>();
    queue.add((fromId, 0));
 
    while (queue.isNotEmpty) {
      final (currentId, dist) = queue.removeFirst();
      final cell = idToCell[currentId];
      if (cell == null) continue;
 
      for (final neighborId in cell.neighbors) {
        if (neighborId == toId) return dist + 1;
        if (!visited.contains(neighborId)) {
          visited.add(neighborId);
          queue.add((neighborId, dist + 1));
        }
      }
    }
    return 9999;
  }
 
  /// Calcola il punteggio del round in base ai tap sbagliati.
  int calculateRoundScore(int wrongTaps) {
    final score =
        GameBConfig.maxScorePerRound - (wrongTaps * GameBConfig.penaltyPerWrongTap);
    return score.clamp(GameBConfig.minScorePerRound, GameBConfig.maxScorePerRound);
  }
 
  /// Inizializza le celle per il Gioco B.
  /// IMPORTANTE: isSafeZone viene mantenuto nei metadati ma NON influenza
  /// il rendering — il HexGridLayer in modalità gameB usa solo distanceToNearest.
  List<HexCell> initializeCells(
    List<HexCell> rawCells,
    List<SafeZone> safeZones,
  ) {
    final safeZoneCellIds = {for (final sz in safeZones) sz.cellId};
    final safeZoneByCell = {for (final sz in safeZones) sz.cellId: sz};
 
    return rawCells.map((cell) {
      final isSafe = safeZoneCellIds.contains(cell.id);
      final sz = safeZoneByCell[cell.id];
      return cell.copyWith(
        state: CellState.hidden,
        isSafeZone: isSafe,
        safeZoneName: sz?.name,
        safeZoneAddress: sz?.address,
        distanceToNearest: null, // nessuna distanza all'avvio
        adjacentSafeZones: 0,
      );
    }).toList();
  }
 
  /// Resetta TUTTE le celle a hidden per un nuovo round.
  /// Azzera distanceToNearest su ogni cella — fondamentale per il Bug 2:
  /// senza questo reset le distanze del round precedente restano visibili.
  List<HexCell> resetCellsForNewRound(List<HexCell> cells) {
    return cells.map((c) => c.copyWith(
          state: CellState.hidden,
          distanceToNearest: null, // <-- reset esplicito distanza
          adjacentSafeZones: 0,
        )).toList();
  }
 
  /// Applica il tap su una cella:
  /// - Cella target → CellState.found, distanceToNearest = 0
  /// - Cella sbagliata → CellState.revealed, distanceToNearest = distanza BFS dal target
  ///
  /// Restituisce celle aggiornate, se è corretta, e la distanza calcolata.
  ({
    List<HexCell> cells,
    bool isCorrect,
    int distance,
  }) tapCell({
    required List<HexCell> cells,
    required int tappedCellId,
    required int targetCellId,
  }) {
    // Ignora tap su celle già rivelate o found (distanza già mostrata)
    final tapped = cells.firstWhere((c) => c.id == tappedCellId,
        orElse: () => throw StateError('Cella $tappedCellId non trovata'));
 
    if (tapped.state != CellState.hidden) {
      return (cells: cells, isCorrect: false, distance: tapped.distanceToNearest ?? 0);
    }
 
    final isCorrect = tappedCellId == targetCellId;
    final distance = isCorrect ? 0 : cellDistance(cells, tappedCellId, targetCellId);
 
    final updatedCells = cells.map((c) {
      if (c.id == tappedCellId) {
        return c.copyWith(
          state: isCorrect ? CellState.found : CellState.revealed,
          distanceToNearest: distance,
        );
      }
      return c;
    }).toList();
 
    return (cells: updatedCells, isCorrect: isCorrect, distance: distance);
  }
 
  /// Seleziona le safe zone per i round in modo casuale senza ripetizioni.
  List<SafeZone> pickRoundTargets(List<SafeZone> safeZones, int count) {
    final shuffled = List<SafeZone>.from(safeZones)..shuffle();
    return shuffled.take(count).toList();
  }
}