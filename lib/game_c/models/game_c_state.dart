import 'package:latlong2/latlong.dart';
import '../../../core/models/safe_zone.dart';

enum GameCPhase {
  loading,
  showPhoto,   // fase 1: utente guarda la foto
  guessing,    // fase 2: utente piazza il pin sulla mappa
  roundResult, // fase 3: feedback con linea + punteggio
  finished,    // partita terminata
}

/// Risultato di un singolo round completato
class GameCRoundResult {
  final SafeZone targetZone;
  final LatLng guessPosition;
  final double distanceMeters;
  final int score;

  const GameCRoundResult({
    required this.targetZone,
    required this.guessPosition,
    required this.distanceMeters,
    required this.score,
  });
}

class GameCState {
  final List<SafeZone> safeZones;

  /// Round corrente (0-based)
  final int currentRound;
  final int totalRounds;

  /// Area target del round corrente
  final SafeZone? targetZone;

  /// Pin piazzato dall'utente (null finché non ha tappato)
  final LatLng? guessPosition;

  /// Risultati dei round completati
  final List<GameCRoundResult> completedRounds;

  final GameCPhase phase;

  const GameCState({
    required this.safeZones,
    required this.currentRound,
    required this.totalRounds,
    required this.completedRounds,
    this.targetZone,
    this.guessPosition,
    this.phase = GameCPhase.loading,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Punteggio cumulativo di tutti i round completati
  int get totalScore => completedRounds.fold(0, (sum, r) => sum + r.score);

  /// Punteggio massimo ottenibile
  int get maxPossibleScore => totalRounds * 5000;

  /// Percentuale punteggio (0–100)
  int get scorePercentage =>
      maxPossibleScore == 0 ? 0 : (totalScore * 100 ~/ maxPossibleScore);

  /// Distanza media in metri su tutti i round completati
  double get averageDistanceMeters {
    if (completedRounds.isEmpty) return 0;
    final total = completedRounds.fold(0.0, (sum, r) => sum + r.distanceMeters);
    return total / completedRounds.length;
  }

  // ── copyWith ──────────────────────────────────────────────────────────────

  GameCState copyWith({
    List<SafeZone>? safeZones,
    int? currentRound,
    int? totalRounds,
    SafeZone? targetZone,
    LatLng? guessPosition,
    bool clearGuess = false,
    List<GameCRoundResult>? completedRounds,
    GameCPhase? phase,
  }) {
    return GameCState(
      safeZones: safeZones ?? this.safeZones,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      targetZone: targetZone ?? this.targetZone,
      guessPosition: clearGuess ? null : (guessPosition ?? this.guessPosition),
      completedRounds: completedRounds ?? this.completedRounds,
      phase: phase ?? this.phase,
    );
  }

  static GameCState initial() => const GameCState(
        safeZones: [],
        currentRound: 0,
        totalRounds: 0,
        completedRounds: [],
        phase: GameCPhase.loading,
      );
}
