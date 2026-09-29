import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hex_cell.dart';

/// Modalità di rendering della griglia esagonale.
/// 
/// Definisce come le celle devono essere colorate in base alle regole specifiche
/// del mini-gioco in corso.
enum HexGridMode { gameA, gameB }

/// Mappa lo stato di una [HexCell] ai colori di rendering della UI.
///
/// Implementa il Single Responsibility Principle (SRP): [HexCell] mantiene
/// solo i dati di dominio, mentre questa classe isola la logica visiva.
abstract final class HexCellColorMapper {
  
  /// Determina il colore di riempimento per una cella in stato [CellState.revealed].
  static Color revealedColor(HexCell cell, HexGridMode mode) {
    // Nel Gioco A, le aree di attesa scoperte vengono evidenziate visivamente.
    if (mode == HexGridMode.gameA && cell.isSafeZone) {
      return AppColors.safeFound;
    }
    
    // Altrimenti, e sempre nel Gioco B, il colore si basa unicamente sulla distanza.
    return _distanceColor(cell.distanceToNearest);
  }

  /// Determina il colore del testo/label sovrapposto alla cella rivelata.
  static Color textColor(HexCell cell) {
    if (cell.isSafeZone) return Colors.white;
    
    final d = cell.distanceToNearest ?? 99;
    // La distanza 2 (giallo chiaro) richiede testo scuro per garantire il contrasto visivo (Accessibilità).
    return d == 2 ? Colors.black87 : Colors.white;
  }

  /// Restituisce il colore corrispondente alla mappa di calore (Distanza).
  static Color _distanceColor(int? distance) {
    switch (distance) {
      case 1:  return AppColors.dist1;
      case 2:  return AppColors.dist2;
      case 3:  return AppColors.dist3;
      default: return AppColors.distFar;
    }
  }
}