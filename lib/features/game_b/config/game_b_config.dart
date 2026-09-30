/// Configurazione centralizzata per il Gioco B (Localizza l'Area).
/// ///
/// Modifica questi valori per bilanciare il gameplay.
class GameBConfig {
  /// Numero di round per partita
  static const int roundsPerGame = 5;

  /// Punteggio massimo per round (primo tap corretto)
  static const int maxScorePerRound = 1000;

  /// Penalità per ogni tap sbagliato
  static const int penaltyPerWrongTap = 50;

  /// Punteggio minimo per round (anche dopo molti tap sbagliati)
  static const int minScorePerRound = 200;

  static const int wrongTapsPerTip = 5;
}
