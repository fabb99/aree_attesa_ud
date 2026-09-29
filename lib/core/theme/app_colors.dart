import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Colori Ufficiali Sonar Cities (Dal PDF) ────────────────────────────────
  static const cosmicCobalt = Color(0xFF333399);
  static const peachOrange  = Color(0xFFFFB06C);
  static const darkGrey     = Color(0xFF282828);
  static const white        = Color(0xFFFFFFFF);

  // ── Backgrounds (Stile pulito da sito web) ─────────────────────────────────
  static const bgDeep        = Color(0xFFF7F7F9); 
  static const bgDark        = Color(0xFFEBEBF0); 
  static const bgCard        = white;
  static const bgCardVariant = Color(0xFFF0F0F5);

  // ── Primary (Elementi UI dell'app) ─────────────────────────────────────────
  static const primary       = cosmicCobalt;
  static const primaryDark   = Color(0xFF252572);
  static const primaryLight  = Color(0xFF5C5CB8);

  // ── Accent (Peach Orange) ──────────────────────────────────────────────────
  static const accent        = peachOrange;
  static const accentLight   = Color(0xFFFFD1AB);
  static const accentDark    = Color(0xFFE69145);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = darkGrey;
  static const textSecondary = Color(0xFF505050);
  static const textDisabled  = Color(0xFF9E9E9E);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border        = Color(0xFFD4D4E0);
  static const borderSubtle  = Color(0xFFEAEAEE);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const safeFound     = Color(0xFF1B5E20);
  static const safeNear      = Color(0xFF2E7D32);
  static const warningYellow = Color(0xFFF9A825);
  static const warningOrange = Color(0xFFE65100);
  static const alertRed      = Color(0xFFC62828);
  static const alertRedDark  = Color(0xFF8B0000);
  static const gold          = peachOrange; // Usiamo il brand per le medaglie/punti

  // ── Distance scale ─────────────────────────────────────────────────────────
  static const dist1         = Color(0xFF2E7D32);
  static const dist2         = Color(0xFFF9A825);
  static const dist3         = Color(0xFFE65100);
  static const distFar       = Color(0xFFC62828);

  // ── Game accents (IDENTITÀ ORIGINALE DEI GIOCHI PRESERVATA) ────────────────
  // GIOCO A (Campo Fiorito - Natura/Verde)
  static const gameA         = Color(0xFF2E7D32);
  static const gameALight    = Color(0xFF388E3C);
  
  // GIOCO B (Localizza l'Area - Blu Istituzionale classico, diverso dal Cobalt)
  static const gameB         = Color(0xFF1565C0); 
  static const gameBLight    = Color(0xFF1976D2);
  
  // GIOCO C (GeoGuesser - Viola fotografico)
  static const gameC         = Color(0xFF6A1B9A);
  static const gameCLight    = Color(0xFF7B1FA2);

  // ── Componenti specifici ───────────────────────────────────────────────────
  static const onColored         = white;
  static const hudBackground     = Color(0xF5FFFFFF);
  static const hudBorder         = Color(0xFFCDD5E0);
  static const dialogBackground  = white;
  static const dialogBorderEnd   = cosmicCobalt;
}