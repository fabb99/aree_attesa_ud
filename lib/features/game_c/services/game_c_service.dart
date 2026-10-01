import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/safe_zone.dart';
import '../config/game_c_config.dart';

/// Logica pura (Business Logic) del Gioco C.
class GameCService {
  // Utilizza latlong2 per calcoli geodetici accurati (considera la curvatura terrestre)
  static const _distance = Distance();

  // ── Calcolo Distanza ────────────────────────────────────────────────────────

  /// Calcola la distanza reale in metri tra il guess dell'utente e il target.
  double distanceMeters(LatLng guess, LatLng target) {
    return _distance.as(LengthUnit.Meter, guess, target);
  }

  // ── Calcolo Punteggio ───────────────────────────────────────────────────────

  /// Calcola il punteggio applicando una curva di decadimento esponenziale.
  ///
  /// Formula: `score = maxScore * e^(-d / k)`
  /// Dove:
  /// - `d` è la distanza in metri.
  /// - `k` è la costante di decadimento [GameCConfig.scoreCurveMeters].
  ///
  /// Questa formula premia molto la precisione estrema e penalizza
  /// progressivamente gli errori, evitando i difetti delle scale lineari.
  int calculateScore(double distMeters) {
    // Taglio netto: oltre la distanza massima il punteggio è zero
    if (distMeters >= GameCConfig.maxDistanceMeters) return 0;
    
    final raw = GameCConfig.maxScorePerRound *
        exp(-distMeters / GameCConfig.scoreCurveMeters);
        
    return raw.round().clamp(0, GameCConfig.maxScorePerRound);
  }

  // ── Utility ─────────────────────────────────────────────────────────────────

  /// Seleziona casualmente le aree di attesa per la partita corrente.
  List<SafeZone> pickRoundTargets(List<SafeZone> safeZones, int count) {
    final shuffled = List<SafeZone>.from(safeZones)..shuffle();
    return shuffled.take(count.clamp(0, shuffled.length)).toList();
  }

  /// Formatta la distanza in un formato user-friendly.
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Restituisce un feedback testuale in base al punteggio ottenuto.
  String scoreLabel(int score) {
    if (score >= 4500) return 'Precisione assoluta!';
    if (score >= 3500) return 'Eccellente!';
    if (score >= 2500) return 'Ottimo!';
    if (score >= 1500) return 'Quasi!';
    if (score >= 500)  return 'Continua ad esplorare!';
    return 'Riprova!';
  }
}