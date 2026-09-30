import '../../../../core/models/hex_cell.dart';
import '../../../../core/models/safe_zone.dart';

/// Fasi di gioco possibili per il Gioco B.
enum GameBPhase { loading, playing, roundResult, finished }

/// Rappresenta il risultato immutabile di un singolo round completato.
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

/// Stato immutabile del Gioco B gestito da Riverpod.
class GameBState {
  final List<HexCell> cells;
  final List<SafeZone> safeZones;

  /// Round corrente (0-based).
  final int currentRound;
  
  /// Numero totale di round previsti per la partita.
  final int totalRounds;

  /// Area di attesa che l'utente deve indovinare nel round corrente.
  final SafeZone? targetZone;

  /// Numero di tap sbagliati nel round corrente.
  final int wrongTaps;

  /// Punteggio corrente del round (diminuisce ad ogni errore).
  final int currentRoundScore;

  /// Storico dei risultati dei round completati.
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

  /// Punteggio cumulativo calcolato sommando i punteggi di tutti i round completati.
  int get totalScore =>
      completedRounds.fold(0, (sum, r) => sum + r.score);

  /// Punteggio massimo teorico ottenibile (tutti i round a punteggio pieno).
  int get maxPossibleScore => totalRounds * 1000;

  /// Percentuale del punteggio finale rispetto al massimo teorico (0–100).
  int get scorePercentage =>
      maxPossibleScore == 0 ? 0 : (totalScore * 100 ~/ maxPossibleScore);

  /// Metodo per ricreare lo stato modificando solo i campi necessari.
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

  /// Stato iniziale "vuoto" mostrato durante il caricamento dei dati.
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