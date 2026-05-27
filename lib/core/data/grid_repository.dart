import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hex_cell.dart';

class GridRepository {
  Future<List<HexCell>> loadGrid() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/grid.json');

    final dynamic decoded = json.decode(jsonString);

    // Supporta sia {"cells": [...]} sia direttamente [...]
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
