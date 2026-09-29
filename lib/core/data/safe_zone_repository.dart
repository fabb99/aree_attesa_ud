import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../models/safe_zone.dart';
import '../models/hex_cell.dart';

class SafeZoneRepository {
  /// Carica il dataset GeoJSON della Protezione Civile FVG.
  ///
  /// Esegue due operazioni fondamentali:
  /// 1. **Filtraggio**: isola solo le aree del comune richiesto ([municipalityIstat]).
  /// 2. **Spatial Join**: incrocia le coordinate geografiche di ogni area con 
  ///    la geometria delle celle ([cells]) per assegnare a ciascuna il corretto `cellId`.
  ///
  /// Il codice ISTAT di default (30129) corrisponde al Comune di Udine.
  Future<List<SafeZone>> loadSafeZones(
    List<HexCell> cells, {
    int? municipalityIstat = 30129,
  }) async {
    final String jsonString =
        await rootBundle.loadString('assets/data/safe_zones.geojson.json');

    final dynamic decoded = json.decode(jsonString);

    List<dynamic> features;

    // Normalizzazione del formato dei dati
    if (decoded is Map && decoded['type'] == 'FeatureCollection') {
      // ── Formato Standard GeoJSON (Protezione Civile FVG) ──
      features = decoded['features'] as List<dynamic>;
    } else if (decoded is List) {
      features = decoded;
    } else if (decoded is Map && decoded.containsKey('safe_zones')) {
      // ── Fallback di retrocompatibilità per vecchio formato custom ──
      return _parseCustomFormat(decoded['safe_zones'] as List<dynamic>);
    } else {
      return [];
    }

    // Filtraggio per comune (se richiesto)
    if (municipalityIstat != null) {
      features = features.where((f) {
        final props = (f as Map<String, dynamic>)['properties'];
        if (props == null) return false;
        final istat = props['municipality_istat'];
        return istat == municipalityIstat;
      }).toList();
    }

    final safeZones = <SafeZone>[];
    int idx = 0;

    for (final f in features) {
      final feature = f as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>?;

      // Ignora feature senza coordinate valide
      if (geometry == null || geometry['type'] != 'Point') continue;

      final coords = geometry['coordinates'] as List<dynamic>;
      final lon = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      final point = LatLng(lat, lon);

      // Esegue lo Spatial Join: trova la cella che racchiude questa coordinata
      final cellId = _findCellId(cells, point);
      
      // Se l'area cade fuori dalla griglia generata, viene scartata
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

  /// Helper per lo Spatial Join: cerca l'ID della cella che contiene il [point].
  int? _findCellId(List<HexCell> cells, LatLng point) {
    for (final cell in cells) {
      if (cell.containsPoint(point)) return cell.id;
    }
    return null;
  }

  /// Supporto per il vecchio formato custom JSON (Legacy).
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
