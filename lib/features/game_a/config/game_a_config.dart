/// Configurazione centralizzata per il Gioco A (Campo Fiorito).
abstract final class GameAConfig {
  /// Raggio dell'esagono in metri (definisce la dimensione della griglia).
  static const double hexRadiusMeters = 183;
  
  /// Numero massimo di tap a disposizione dell'utente per scoprire tutte le aree.
  static const int movesPerGame = 100;
  
  /// Numero di tap "sbagliati" (su celle vuote) necessari prima che appaia un suggerimento.
  static const int wrongTapsPerTip = 7;
}