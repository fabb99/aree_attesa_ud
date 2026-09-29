import 'package:latlong2/latlong.dart';

/// Modello che rappresenta un'area di attesa della Protezione Civile.
class SafeZone {
  final int id;
  final int cellId; // assegnato dopo lo spatial join con la griglia
  final String name;
  final String address;
  final LatLng position;

  const SafeZone({
    required this.id,

    /// ID della cella esagonale che contiene questa area. 
    /// Viene assegnato dinamicamente a runtime tramite spatial join.
    required this.cellId,

    required this.name,
    required this.address,

    /// Coordinate geografiche esatte dell'area.
    required this.position,
  });

  /// Costruisce una [SafeZone] parsando una Feature in formato GeoJSON 
  /// (standard open data utilizzato dalla Protezione Civile FVG).
  ///
  /// Nota: chiamare questo costruttore solo dopo aver risolto [cellId] 
  /// tramite un'operazione di spatial join con la griglia.
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

    // Risoluzione dinamica del nome: preferisce la descrizione, altrimenti la località
    final name = description.isNotEmpty ? description : localita;

    // Composizione dell'indirizzo nel formato "Via X, Comune"
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

  /// Crea una copia associando l'area a una nuova cella.
  SafeZone copyWithCellId(int newCellId) => SafeZone(
        id: id,
        cellId: newCellId,
        name: name,
        address: address,
        position: position,
      );
}
