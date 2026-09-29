import 'package:latlong2/latlong.dart';

/// Costanti condivise tra tutti i moduli dell'app.

abstract final class AppConstants {
  // ── Mappa ─────────────────────────────────────────────────────────────────

  /// Centro geografico di Udine — usato come centro iniziale della mappa
  /// in tutte le schermate di gioco.
  static const LatLng udineCenter = LatLng(46.0648, 13.2347);

  /// Zoom iniziale standard per le mappe di gioco.
  static const double defaultZoom = 13.5;

  /// Zoom minimo consentito.
  static const double minZoom = 12.0;

  /// Zoom massimo consentito.
  static const double maxZoom = 18.0;
}
