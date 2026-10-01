/// Configurazione centralizzata per il Gioco C.
abstract final class GameCConfig {
  /// Numero di round per partita.
  static const int roundsPerGame = 5;

  /// Punteggio massimo assegnato per un guess perfetto (distanza 0 metri).
  static const int maxScorePerRound = 5000;

  /// Costante di decadimento della curva esponenziale (in metri).
  /// Regola la "severità" della perdita di punti all'aumentare della distanza.
  /// A [scoreCurveMeters] metri di distanza, il punteggio si riduce a circa il 37% (1/e).
  static const double scoreCurveMeters = 1000.0;

  /// Distanza massima (in metri) oltre la quale il punteggio è forzato a 0.
  static const double maxDistanceMeters = 8000.0;
}