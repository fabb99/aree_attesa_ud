import 'package:flutter/material.dart';
//-----VERSIONE DARK
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const bgDeep        = Color(0xFF0A0E1A);
  static const bgDark        = Color(0xFF0D1423);
  static const bgCard        = Color(0xFF111827);
  static const bgCardVariant = Color(0xFF1C2333);
                            
  // ── Primary (blu istituzionale) ────────────────────────────────────────────
  static const primary       = Color(0xFF1565C0);
  static const primaryDark   = Color(0xFF0D47A1);
  static const primaryLight  = Color(0xFF42A5F5);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFECEFF1);
  static const textSecondary = Color(0xFF90A4AE);
  static const textDisabled  = Color(0xFF546E7A);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border        = Color(0xFF1E2D40);
  static const borderSubtle  = Color(0xFF162030);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const safeFound     = Color(0xFF1B5E20);
  static const safeNear      = Color(0xFF43A047);
  static const warningYellow = Color(0xFFFFEB3B);
  static const warningOrange = Color(0xFFFF9800);
  static const alertRed      = Color(0xFFEF5350);
  static const alertRedDark  = Color(0xFFB71C1C);
  static const alertRedDeep  = Color(0xFF8B0000);
  static const gold          = Color(0xFFFFD700);

  // ── Distance scale ─────────────────────────────────────────────────────────
  static const dist1         = Color(0xFF43A047);
  static const dist2         = Color(0xFFFFEB3B);
  static const dist3         = Color(0xFFFF9800);
  static const distFar       = Color(0xFFE64A19);

  // ── Game accents ───────────────────────────────────────────────────────────
  static const gameA         = Color(0xFF2E7D32);
  static const gameALight    = Color(0xFF4CAF50);
  static const gameB         = Color(0xFF1565C0);
  static const gameBLight    = Color(0xFF42A5F5);
  static const gameC         = Color(0xFF6A1B9A);
  static const gameCLight    = Color(0xFFCE93D8);
  
  //-----------
  // ── Componenti specifici ───────────────────────────────────────────────────

  /// Testo su sfondi colorati (bottoni, banner, HUD) — sempre bianco
  static const onColored         = Color(0xFFFFFFFF);

  /// Sfondo HUD — abbastanza opaco da essere leggibile sulla mappa
  static const hudBackground     = Color(0xE6101828); // bgDeep con alpha 90%

  /// Bordo HUD — visibile sulla mappa
  static const hudBorder         = Color(0x661E2D40);

  /// Sfondo dialog
  static const dialogBackground  = Color(0xFF111827);

  /// Bordo dialog termina
  static const dialogBorderEnd   = Color(0xFFC62828);
}