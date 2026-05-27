import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../../core/models/safe_zone.dart';
import '../config/game_c_config.dart';

/// Logica pura del Gioco C.
/// Nessuna dipendenza da Flutter o Riverpod — facilmente testabile.
class GameCService {
  // Usa la Distance di latlong2 per calcoli geodetici accurati
  static const _distance = Distance();

  // ── Distanza ──────────────────────────────────────────────────────────────

  /// Distanza in metri tra guess e target (Haversine).
  double distanceMeters(LatLng guess, LatLng target) {
    return _distance.as(LengthUnit.Meter, guess, target);
  }

  // ── Punteggio ─────────────────────────────────────────────────────────────

  /// Curva punteggio esponenziale stile GeoGuesser.
  ///
  /// Formula: score = maxScore * e^(-d / D)
  ///   d = distanza in metri
  ///   D = GameCConfig.scoreCurveMeters (costante di decadimento)
  ///
  /// Esempi con D=500:
  ///   0m   → 5000 pt
  ///   100m → ~4095 pt
  ///   500m → ~1839 pt
  ///   1km  → ~676 pt
  ///   2km  → ~91 pt
  ///   5km  → 0 pt (clamp)
  int calculateScore(double distMeters) {
    if (distMeters >= GameCConfig.maxDistanceMeters) return 0;
    final raw = GameCConfig.maxScorePerRound *
        exp(-distMeters / GameCConfig.scoreCurveMeters);
    return raw.round().clamp(0, GameCConfig.maxScorePerRound);
  }

  // ── Selezione target ──────────────────────────────────────────────────────

  /// Seleziona [count] safe zone casuali senza ripetizioni.
  List<SafeZone> pickRoundTargets(List<SafeZone> safeZones, int count) {
    final shuffled = List<SafeZone>.from(safeZones)..shuffle();
    return shuffled.take(count.clamp(0, shuffled.length)).toList();
  }

  // ── Label distanza leggibile ──────────────────────────────────────────────

  /// Formatta la distanza in modo leggibile (es. "234 m", "1.2 km").
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  // ── Label punteggio ───────────────────────────────────────────────────────

  String scoreLabel(int score) {
    if (score >= 4500) return '🎯 Precisione assoluta!';
    if (score >= 3500) return '🏆 Eccellente!';
    if (score >= 2500) return '👍 Ottimo!';
    if (score >= 1500) return '📚 Quasi!';
    if (score >= 500)  return '🗺️ Continua ad esplorare!';
    return '💪 Riprova!';
  }
}
