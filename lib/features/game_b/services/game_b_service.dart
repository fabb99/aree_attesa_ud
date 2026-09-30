import 'dart:collection';
import '../../../../core/models/hex_cell.dart';
import '../../../../core/models/safe_zone.dart';
import '../config/game_b_config.dart';
 
/// Logica pura (Business Logic) del Gioco B.
class GameBService {
  
  /// Calcola la distanza in "salti" tra due celle tramite BFS sul grafo di adiacenza.
  /// 
  /// In questo gioco, quando l'utente sbaglia, il feedback visivo (colore e numero) 
  /// dipende da quante celle lo separano dal target.
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
 
  /// Calcola il punteggio del round scalando una penalità per ogni errore.
  int calculateRoundScore(int wrongTaps) {
    final score =
        GameBConfig.maxScorePerRound - (wrongTaps * GameBConfig.penaltyPerWrongTap);
    return score.clamp(GameBConfig.minScorePerRound, GameBConfig.maxScorePerRound);
  }
 
  /// Inizializza le celle per il Gioco B.
  /// 
  /// Mantiene il flag `isSafeZone` nei metadati, ma la griglia viene renderizzata
  /// usando solo `distanceToNearest`, per non suggerire visivamente la risposta.
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
        distanceToNearest: null, // Azzerata all'avvio
        adjacentSafeZones: 0,
      );
    }).toList();
  }
 
  /// Resetta lo stato visivo di tutte le celle per iniziare un nuovo round.
  /// 
  /// Azzera `distanceToNearest` per evitare che l'utente veda i suggerimenti 
  /// (colori e numeri) derivanti dal round precedente.
  List<HexCell> resetCellsForNewRound(List<HexCell> cells) {
    return cells.map((c) => c.copyWith(
          state: CellState.hidden,
          distanceToNearest: null, // Reset esplicito della distanza
          adjacentSafeZones: 0,
        )).toList();
  }
 
  /// Elabora l'azione di tocco (tap) su una specifica cella.
  ///
  /// Restituisce un record Dart 3.0 contenente:
  /// - `cells`: L'array aggiornato di celle
  /// - `isCorrect`: Booleano, true se la cella toccata era il target
  /// - `distance`: Distanza calcolata (0 se corretto, >0 se errato)
  ({
    List<HexCell> cells,
    bool isCorrect,
    int distance,
  }) tapCell({
    required List<HexCell> cells,
    required int tappedCellId,
    required int targetCellId,
  }) {
    // Ignora i tap su celle che sono già state rivelate (l'utente sa già la distanza da lì)
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
 
  /// Seleziona le aree di attesa target per tutti i round della partita,
  /// mescolandole casualmente senza ripetizioni.
  List<SafeZone> pickRoundTargets(List<SafeZone> safeZones, int count) {
    final shuffled = List<SafeZone>.from(safeZones)..shuffle();
    return shuffled.take(count).toList();
  }
}