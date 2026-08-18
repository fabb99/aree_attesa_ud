import 'package:flutter/material.dart';

// ── SONAR CITIES · Light theme ────────────────────────────────────────────────
// Palette brand:
//   Cosmic Cobalt  #333399
//   Peach Orange   #FFB06C
//   Dark Grey      #282828
//   White          #FFFFFF

abstract final class AppColors {
// ── Colori Ufficiali Sonar Cities (Dal PDF) ────────────────────────────────
  static const cosmicCobalt = Color(0xFF333399);
  static const peachOrange  = Color(0xFFFFB06C);
  static const darkGrey     = Color(0xFF282828);
  static const white        = Color(0xFFFFFFFF);


  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const bgDeep        = Color(0xFF333399);//Color(0xFFF0F0FA); // bianco con hint cobalt
  static const bgDark        = Color(0xFFE4E4F5); // leggermente più scuro
  static const bgCard        = Color(0xFFFFFFFF); // bianco puro
  static const bgCardVariant = Color(0xFFF5F5FF); // bianco con tint cobalt

  // ── Primary — Cosmic Cobalt ────────────────────────────────────────────────
  static const primary       = Color(0xFF333399);
  static const primaryDark   = Color(0xFF252572);
  static const primaryLight  = Color(0xFF5555BB);

  // ── Accent — Peach Orange ─────────────────────────────────────────────────
  static const accent        = Color(0xFFFFB06C);
  static const accentLight   = Color(0xFFFFCA9A);
  static const accentDark    = Color(0xFFCC7733); // più scuro per contrasto su bianco

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF); //Color(0xFF5555BB);//Color(0xFF1A1A33); // quasi nero cobalt
  static const textSecondary = Color(0xFF1A2332); //Color(0xFFE4E4F5);//Color(0xFF444466); // grigio cobalt
  static const textDisabled  = Color.fromARGB(255, 81, 81, 94);//Color(0xFF9999BB); // grigio chiaro

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border        = Color(0xFFCCCCEE);
  static const borderSubtle  = Color(0xFFE5E5F5);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const safeFound     = Color(0xFF1B5E20);
  static const safeNear      = Color(0xFF2E7D32);
  static const warningYellow = Color(0xFFF9A825);
  static const warningOrange = Color(0xFFE65100);
  static const alertRed      = Color(0xFFC62828);
  static const alertRedDark  = Color(0xFF8B0000);
  static const alertRedDeep  = Color(0xFF8B0000);

  // ── Gold → Peach Orange ───────────────────────────────────────────────────
  static const gold          = accentDark; // alias brand-aware

  // ── Distance scale ─────────────────────────────────────────────────────────
  static const dist1         = Color(0xFF2E7D32);
  static const dist2         = Color(0xFFF9A825);
  static const dist3         = Color(0xFFE65100);
  static const distFar       = Color(0xFFC62828);

  // ── Game accents ───────────────────────────────────────────────────────────
  static const gameA         = Color(0xFF2E7D32);
  static const gameALight    = Color(0xFF388E3C);
  static const gameB         = Color(0xFF333399); // Cosmic Cobalt
  static const gameBLight    = Color(0xFF5555BB);
  static const gameC         = Color(0xFF6A1B9A);
  static const gameCLight    = Color(0xFF7B1FA2);

  // static const gameA         = Color(0xFFCC7733); // accentDark
  // static const gameALight    = Color(0xFFFFB06C); // Peach Orange
  // static const gameB         = Color(0xFFCC7733); // accentDark
  // static const gameBLight    = Color(0xFFFFB06C); // Peach Orange
  // static const gameC         = Color(0xFFCC7733); // accentDark
  // static const gameCLight    = Color(0xFFFFB06C); // Peach Orange

  // ── Componenti specifici ───────────────────────────────────────────────────
  static const onColored         = Color(0xFFFFFFFF);
  static const hudBackground     = Color(0xF5FFFFFF);
  static const hudBorder         = Color(0xFFCCCCEE);
  static const dialogBackground  = Color(0xFFFFFFFF);
  static const dialogBorderEnd   = Color(0xFFC62828);
}