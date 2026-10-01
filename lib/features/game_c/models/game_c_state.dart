import 'package:latlong2/latlong.dart';
import '../../../../core/models/safe_zone.dart';

/// Fasi sequenziali del Gioco C.
enum GameCPhase {
  loading,
  showPhoto,   // Fase 1: L'utente osserva la foto dell'area
  guessing,    // Fase 2: L'utente posiziona il pin sulla mappa
  roundResult, // Fase 3: Feedback visivo (distanza e punteggio)
  finished,    // Partita conclusa
}

/// Risultato immutabile di un singolo round del Gioco C.
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

/// Stato principale del Gioco C gestito da Riverpod.
class GameCState {
  final List<SafeZone> safeZones;

  /// Round corrente (0-based).
  final int currentRound;
  final int totalRounds;

  /// Area bersaglio del round corrente.
  final SafeZone? targetZone;

  /// Posizione del pin piazzato dall'utente (null finché non tocca la mappa).
  final LatLng? guessPosition;

  /// Risultati dei round completati.
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

  // ── Computed Properties (Getter calcolati al volo) ───────────────────────

  /// Punteggio cumulativo totale.
  int get totalScore => completedRounds.fold(0, (sum, r) => sum + r.score);

  /// Punteggio massimo teorico ottenibile in questa partita.
  int get maxPossibleScore => totalRounds * 5000;

  /// Percentuale del punteggio ottenuto rispetto al massimo.
  int get scorePercentage =>
      maxPossibleScore == 0 ? 0 : (totalScore * 100 ~/ maxPossibleScore);

  /// Distanza media (in metri) registrata su tutti i round giocati.
  double get averageDistanceMeters {
    if (completedRounds.isEmpty) return 0;
    final total = completedRounds.fold(0.0, (sum, r) => sum + r.distanceMeters);
    return total / completedRounds.length;
  }

  // ── Modificatori ────────────────────────────────────────────────────────────

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
      // Se clearGuess è true, forza il pin a null per il nuovo round
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