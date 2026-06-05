/// Configurazione centralizzata per il Gioco C (GeoGuesser-style).
/// Modifica questi valori per bilanciare il gameplay.
class GameCConfig {
  /// Numero di round per partita
  static const int roundsPerGame = 5;

  /// Punteggio massimo per round (guess perfetta = 0 metri)
  static const int maxScorePerRound = 5000;

  /// Costante di decadimento della curva esponenziale (in metri).
  /// A [scoreCurveMeters] metri di distanza il punteggio è ~63% del massimo.
  /// Abbassa il valore per rendere il gioco più severo.
  static const double scoreCurveMeters = 1000.0;

  /// Distanza massima oltre la quale il punteggio è 0
  static const double maxDistanceMeters = 8000.0;

  /// Centro mappa Udine
  static const double mapCenterLat = 46.0648;
  static const double mapCenterLon = 13.2347;

  /// Zoom iniziale della mappa di guess
  static const double initialZoom = 13.5;
}
