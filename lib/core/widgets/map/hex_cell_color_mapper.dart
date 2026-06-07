import 'package:aree_attesa_ud/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../models/hex_cell.dart';


/// Mappa lo stato di una [HexCell] ai colori di rendering.
///
/// Questa classe esiste per rispettare il principio SRP:
/// [HexCell] è un domain object puro (dati geografici + stato di gioco)
/// e non deve conoscere nulla della UI.
/// Tutta la logica "che colore ha questa cella?" vive qui, nel layer widget.
///
/// Uso:
/// ```dart
/// final color = HexCellColorMapper.revealedColor(cell, mode);
/// final textColor = HexCellColorMapper.textColor(cell);
/// ```
abstract final class HexCellColorMapper {
  

  // ── API pubblica ──────────────────────────────────────────────────────────

  /// Colore di riempimento per una cella in stato [CellState.revealed].
  ///
  /// [mode] controlla se applicare il colore speciale per le safe zone:
  /// - [HexGridMode.gameA]: le safe zone rivelate diventano verde scuro.
  /// - [HexGridMode.gameB]: si usa solo la distanza, mai il verde safe zone
  ///   (nel Gioco B la safe zone non deve essere visivamente distinguibile
  ///   dalle altre celle rivelate).
  static Color revealedColor(HexCell cell, HexGridMode mode) {
    if (mode == HexGridMode.gameA && cell.isSafeZone) {
      return  AppColors.safeFound;
    }
    return _distanceColor(cell.distanceToNearest);
  }

  /// Colore del testo/label sulla cella rivelata.
  ///
  /// Il giallo (distanza 2) richiede testo scuro per contrasto;
  /// tutti gli altri casi usano bianco.
  static Color textColor(HexCell cell) {
    if (cell.isSafeZone) return Colors.white;
    final d = cell.distanceToNearest ?? 99;
    return d == 2 ? Colors.black87 : Colors.white;
  }

  // ── Privato ───────────────────────────────────────────────────────────────

  static Color _distanceColor(int? distance) {
    switch (distance) {
      case 1:  return AppColors.dist1;
      case 2:  return AppColors.dist2;
      case 3:  return AppColors.dist3;
      default: return AppColors.distFar;
    }
  }
}

/// Modalità di rendering della griglia esagonale.
/// Definita qui perché strettamente legata alla logica di colorazione.
enum HexGridMode { gameA, gameB }
