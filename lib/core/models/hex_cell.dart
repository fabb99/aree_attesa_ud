import 'package:latlong2/latlong.dart';

enum CellState { hidden, revealed, found }

class HexCell {
  final int id;
  final LatLng center;
  final List<LatLng> vertices; // 6 vertici in lat/lon
  final List<int> neighbors;

  // Stato di gioco (mutabile tramite copyWith)
  final CellState state;

  // Distanza alla safe zone più vicina (calcolata da GameService)
  final int? distanceToNearest;

  // Quante safe zone nelle celle adiacenti (distanza 1)
  final int adjacentSafeZones;

  // true se questa cella è una safe zone
  final bool isSafeZone;

  // Nome e indirizzo (se isSafeZone)
  final String? safeZoneName;
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
      distanceToNearest: distanceToNearest == _sentinel
        ? this.distanceToNearest
        : distanceToNearest as int?,
      adjacentSafeZones: adjacentSafeZones ?? this.adjacentSafeZones,
      isSafeZone: isSafeZone ?? this.isSafeZone,
      safeZoneName: safeZoneName ?? this.safeZoneName,
      safeZoneAddress: safeZoneAddress ?? this.safeZoneAddress,
    );
  }

  static const Object _sentinel = Object();

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

  /// Controlla se un punto (lat/lon) è dentro il poligono esagonale
  /// usando il ray-casting algorithm
  bool containsPoint(LatLng point) {
    int n = vertices.length;
    bool inside = false;
    double x = point.longitude, y = point.latitude;

    for (int i = 0, j = n - 1; i < n; j = i++) {
      double xi = vertices[i].longitude, yi = vertices[i].latitude;
      double xj = vertices[j].longitude, yj = vertices[j].latitude;

      bool intersect =
          ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }
}
