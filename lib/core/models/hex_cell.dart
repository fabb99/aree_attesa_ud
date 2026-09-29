import 'package:latlong2/latlong.dart';

/// Stati possibili per una cella esagonale nella griglia di gioco.
enum CellState { hidden, revealed, found }

/// Modello di dominio che rappresenta una singola cella esagonale della mappa.
///
/// Contiene sia i dati geometrici statici (centro, vertici, vicini) generati
/// pre-partita, sia lo stato mutabile del gioco (distanza, se è stata rivelata, ecc.).
class HexCell {
  // ── Dati Geometrici (Immutabili) ──────────────────────────────────────────
  final int id;
  final LatLng center;

  /// I 6 vertici dell'esagono in coordinate lat/lon.
  final List<LatLng> vertices; 

  /// ID delle celle adiacenti (per visite BFS/calcolo distanze).
  final List<int> neighbors;

  // ── Stato di Gioco (Mutabile tramite copyWith) ────────────────────────────
  
  /// Stato visivo della cella.
  final CellState state;
  
  /// Distanza alla safe zone più vicina (calcolata da GameService)
  final int? distanceToNearest;

  /// Quante safe zone nelle celle adiacenti (distanza 1)
  final int adjacentSafeZones;

  /// true se questa cella è una safe zone
  final bool isSafeZone;

  /// Nome dell'area di attesa (se [isSafeZone] è true).
  final String? safeZoneName;

  /// Indirizzo dell'area di attesa (se [isSafeZone] è true).
  final String? safeZoneAddress;

  const HexCell({
    required this.id,
    required this.center,
    required this.vertices,
    required this.neighbors,
    this.state = CellState.hidden,
    this.distanceToNearest,
    this.adjacentSafeZones = 0,
    this.isSafeZone = false,
    this.safeZoneName,
    this.safeZoneAddress,
  });

  /// Oggetto sentinella per distinguere l'omissione del parametro 
  /// dal passaggio esplicito di un valore null nel [copyWith].
  static const Object _sentinel = Object();


  /// Crea una copia della cella aggiornando solo i campi specificati.
  HexCell copyWith({
    CellState? state,
    Object? distanceToNearest = _sentinel,
    int? adjacentSafeZones,
    bool? isSafeZone,
    String? safeZoneName,
    String? safeZoneAddress,
  }) {
    return HexCell(
      id: id,
      center: center,
      vertices: vertices,
      neighbors: neighbors,
      state: state ?? this.state,
      // Permette di resettare esplicitamente a null se viene passato null
      distanceToNearest: distanceToNearest == _sentinel
        ? this.distanceToNearest
        : distanceToNearest as int?,
      adjacentSafeZones: adjacentSafeZones ?? this.adjacentSafeZones,
      isSafeZone: isSafeZone ?? this.isSafeZone,
      safeZoneName: safeZoneName ?? this.safeZoneName,
      safeZoneAddress: safeZoneAddress ?? this.safeZoneAddress,
    );
  }



  /// Deserializzazione da JSON (usata per caricare la griglia pre-calcolata).
  factory HexCell.fromJson(Map<String, dynamic> json) {
    final centerMap = json['center'] as Map<String, dynamic>;
    final verticesList = (json['vertices'] as List)
        .map((v) => LatLng(
              (v['lat'] as num).toDouble(),
              (v['lon'] as num).toDouble(),
            ))
        .toList();
    final neighborsList =
        (json['neighbors'] as List).map((n) => n as int).toList();

    return HexCell(
      id: json['id'] as int,
      center: LatLng(
        (centerMap['lat'] as num).toDouble(),
        (centerMap['lon'] as num).toDouble(),
      ),
      vertices: verticesList,
      neighbors: neighborsList,
    );
  }

/// Verifica se una coordinata [point] si trova all'interno di questo esagono.
  /// 
  /// Implementa il **Ray-casting algorithm** (Point in Polygon): traccia un 
  /// raggio orizzontale dal punto e conta quante volte interseca i lati del 
  /// poligono. Un numero dispari significa che il punto è interno.
  bool containsPoint(LatLng point) {
    int n = vertices.length;
    bool inside = false;
    double x = point.longitude, y = point.latitude;

    for (int i = 0, j = n - 1; i < n; j = i++) {
      double xi = vertices[i].longitude, yi = vertices[i].latitude;
      double xj = vertices[j].longitude, yj = vertices[j].latitude;


      // Controlla l'intersezione del raggio con il segmento i-j
      bool intersect =
          ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }
}
