import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../models/safe_zone.dart';
import '../models/hex_cell.dart';

class SafeZoneRepository {
  /// Carica il GeoJSON della Protezione Civile FVG e restituisce le aree
  /// di attesa, con il [cellId] assegnato tramite spatial join sulla griglia.
  ///
  /// [cells] deve essere già caricato da [GridRepository].
  /// [municipalityIstat] filtra per comune (default: 30129).
  /// Passa `null` per caricare tutte le aree senza filtro.
  Future<List<SafeZone>> loadSafeZones(
    List<HexCell> cells, {
    int? municipalityIstat = 30129,
  }) async {
    final String jsonString =
        await rootBundle.loadString('assets/data/safe_zones.geojson.json');

    final dynamic decoded = json.decode(jsonString);

    List<dynamic> features;

    if (decoded is Map && decoded['type'] == 'FeatureCollection') {
      // ── GeoJSON FeatureCollection (formato Protezione Civile FVG) ──
      features = decoded['features'] as List<dynamic>;
    } else if (decoded is List) {
      features = decoded;
    } else if (decoded is Map && decoded.containsKey('safe_zones')) {
      // ── Vecchio formato custom ──
      return _parseCustomFormat(decoded['safe_zones'] as List<dynamic>);
    } else {
      return [];
    }

    // Filtra per comune se richiesto
    if (municipalityIstat != null) {
      features = features.where((f) {
        final props = (f as Map<String, dynamic>)['properties'];
        if (props == null) return false;
        final istat = props['municipality_istat'];
        return istat == municipalityIstat;
      }).toList();
    }

    // Spatial join: per ogni safe zone trova la cella che la contiene
    final safeZones = <SafeZone>[];
    int idx = 0;

    for (final f in features) {
      final feature = f as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry == null || geometry['type'] != 'Point') continue;

      final coords = geometry['coordinates'] as List<dynamic>;
      final lon = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      final point = LatLng(lat, lon);

      // Trova la cella che contiene questo punto
      final cellId = _findCellId(cells, point);
      if (cellId == null) continue; // punto fuori dalla griglia → scarta
      
      safeZones.add(SafeZone.fromGeoJsonFeature(
        id: idx,
        cellId: cellId,
        feature: feature,
      ));
      idx++;
    }

    return safeZones;
  }

  /// Spatial join: ritorna l'id della cella che contiene il punto,
  /// oppure null se nessuna cella lo contiene.
  int? _findCellId(List<HexCell> cells, LatLng point) {
    for (final cell in cells) {
      if (cell.containsPoint(point)) return cell.id;
    }
    return null;
  }

  /// Supporto retrocompatibile per il vecchio formato custom JSON.
  List<SafeZone> _parseCustomFormat(List<dynamic> list) {
    return list.whereType<Map<String, dynamic>>().map((z) {
      return SafeZone(
        id: z['id'] as int,
        cellId: z['cell_id'] as int,
        name: z['name'] as String,
        address: z['address'] as String,
        position: LatLng(
          (z['lat'] as num).toDouble(),
          (z['lon'] as num).toDouble(),
        ),
      );
    }).toList();
  }
}
