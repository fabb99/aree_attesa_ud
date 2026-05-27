import 'package:latlong2/latlong.dart';

class SafeZone {
  final int id;
  final int cellId; // assegnato dopo lo spatial join con la griglia
  final String name;
  final String address;
  final LatLng position;

  const SafeZone({
    required this.id,
    required this.cellId,
    required this.name,
    required this.address,
    required this.position,
  });

  /// Costruisce da GeoJSON Feature (Protezione Civile FVG)
  /// Chiamare dopo aver risolto cellId con spatial join.
  factory SafeZone.fromGeoJsonFeature({
    required int id,
    required int cellId,
    required Map<String, dynamic> feature,
  }) {
    final props = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;

    // GeoJSON: [longitude, latitude]
    final lon = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();

    final description =
        (props['dati_generali.description'] as String? ?? '').trim();
    final localita =
        (props['dati_generali.localita'] as String? ?? '').trim();
    final indirizzo =
        (props['dati_generali.indirizzo'] as String? ?? '').trim();
    final municipality =
        (props['municipality'] as String? ?? '').trim();

    // Nome: preferisce description, fallback su localita
    final name = description.isNotEmpty ? description : localita;

    // Indirizzo: "Via X, Comune"
    final addressParts = [
      if (indirizzo.isNotEmpty) indirizzo,
      if (municipality.isNotEmpty) municipality,
    ];
    final address = addressParts.join(', ');

    return SafeZone(
      id: id,
      cellId: cellId,
      name: name,
      address: address,
      position: LatLng(lat, lon),
    );
  }

  SafeZone copyWithCellId(int newCellId) => SafeZone(
        id: id,
        cellId: newCellId,
        name: name,
        address: address,
        position: position,
      );
}
