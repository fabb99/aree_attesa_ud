import '../../../../core/models/hex_cell.dart';
import '../../../../core/models/safe_zone.dart';

enum GameBPhase { loading, playing, roundResult, finished }

/// Rappresenta il risultato di un singolo round completato
class RoundResult {
  final SafeZone targetZone;
  final int tapsUsed;
  final int score;

  const RoundResult({
    required this.targetZone,
    required this.tapsUsed,
    required this.score,
  });
}

class GameBState {
  final List<HexCell> cells;
  final List<SafeZone> safeZones;

  /// Round corrente (0-based)
  final int currentRound;
  final int totalRounds;

  /// Area di attesa da indovinare nel round corrente
  final SafeZone? targetZone;

  /// Numero di tap sbagliati nel round corrente
  final int wrongTaps;

  /// Punteggio corrente del round (scende ad ogni tap sbagliato)
  final int currentRoundScore;

  /// Risultati dei round completati
  final List<RoundResult> completedRounds;

  final GameBPhase phase;

  const GameBState({
    required this.cells,
    required this.safeZones,
    required this.currentRound,
    required this.totalRounds,
    required this.wrongTaps,
    required this.currentRoundScore,
    required this.completedRounds,
    this.targetZone,
    this.phase = GameBPhase.loading,
  });

  /// Punteggio cumulativo di tutti i round completati
  int get totalScore =>
      completedRounds.fold(0, (sum, r) => sum + r.score);

  /// Punteggio massimo ottenibile (tutti i round a punteggio pieno)
  int get maxPossibleScore => totalRounds * 1000;

  /// Percentuale punteggio finale (0–100)
  int get scorePercentage =>
      maxPossibleScore == 0 ? 0 : (totalScore * 100 ~/ maxPossibleScore);

  GameBState copyWith({
    List<HexCell>? cells,
    List<SafeZone>? safeZones,
    int? currentRound,
    int? totalRounds,
    SafeZone? targetZone,
    int? wrongTaps,
    int? currentRoundScore,
    List<RoundResult>? completedRounds,
    GameBPhase? phase,
  }) {
    return GameBState(
      cells: cells ?? this.cells,
      safeZones: safeZones ?? this.safeZones,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      targetZone: targetZone ?? this.targetZone,
      wrongTaps: wrongTaps ?? this.wrongTaps,
      currentRoundScore: currentRoundScore ?? this.currentRoundScore,
      completedRounds: completedRounds ?? this.completedRounds,
      phase: phase ?? this.phase,
    );
  }

  static GameBState initial() => const GameBState(
        cells: [],
        safeZones: [],
        currentRound: 0,
        totalRounds: 0,
        wrongTaps: 0,
        currentRoundScore: 0,
        completedRounds: [],
        phase: GameBPhase.loading,
      );
}
