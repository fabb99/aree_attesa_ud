import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hex_cell.dart';

/// Repository responsabile del caricamento della griglia esagonale.
/// 
/// La griglia viene pre-calcolata offline e salvata come asset statico
/// per garantire prestazioni ottimali a runtime, evitando complessi
/// calcoli geometrici di tassellatura sul dispositivo.
class GridRepository {
  /// Carica e decodifica il file JSON contenente i dati della griglia.
  /// 
  /// Gestisce in modo trasparente diverse possibili strutture del JSON 
  /// (sia array diretto `[...]` che mappa con chiave `{"cells": [...]}`).
  Future<List<HexCell>> loadGrid() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/grid.json');

    final dynamic decoded = json.decode(jsonString);

    
    final List<dynamic> cellsJson;
    if (decoded is List) {
      cellsJson = decoded;
    } else if (decoded is Map) {
      final raw = decoded['cells'];
      if (raw == null) {
        throw StateError(
          'grid.json non contiene la chiave "cells". '
          'Struttura attesa: {"cells": [...]}',
        );
      }
      cellsJson = raw as List<dynamic>;
    } else {
      throw StateError('grid.json ha un formato non riconosciuto.');
    }

    return cellsJson
        .whereType<Map<String, dynamic>>()
        .map(HexCell.fromJson)
        .toList();
  }
}
