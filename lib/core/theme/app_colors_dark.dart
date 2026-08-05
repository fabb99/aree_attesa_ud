import 'package:flutter/material.dart';

// ── SONAR CITIES · Dark theme ─────────────────────────────────────────────────
// Palette brand:
//   Cosmic Cobalt  #333399
//   Peach Orange   #FFB06C
//   Dark Grey      #282828
//   White          #FFFFFF

abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  // Derivati dal Dark Grey (#282828) con una sfumatura cobalt
  static const bgDeep        = Color(0xFF0D0D1E); // quasi-nero cobalt
  static const bgDark        = Color(0xFF12122A); // sfondo card scuro
  static const bgCard        = Color(0xFF1A1A35); // card principale
  static const bgCardVariant = Color(0xFF222245); // card secondaria

  // ── Primary — Cosmic Cobalt ────────────────────────────────────────────────
  static const primary       = Color(0xFF333399); // brand primario
  static const primaryDark   = Color(0xFF252572); // hover / pressed
  static const primaryLight  = Color(0xFF6666BB); // tint chiaro

  // ── Accent — Peach Orange ─────────────────────────────────────────────────
  // Usato dove prima c'era gold/warningYellow: dà calore e riconoscibilità
  static const accent        = Color(0xFFFFB06C); // Peach Orange puro
  static const accentLight   = Color(0xFFFFCA9A); // tint chiaro
  static const accentDark    = Color(0xFFCC8040); // ombra

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFECECFF); // bianco con hint cobalt
  static const textSecondary = Color(0xFFAAAACC); // grigio-cobalt
  static const textDisabled  = Color(0xFF55556A); // quasi invisibile

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border        = Color(0xFF2A2A55); // linea sottile cobalt
  static const borderSubtle  = Color(0xFF1A1A3A); // quasi invisibile

  // ── Semantic (invariati — significato cromatico universale) ────────────────
  static const safeFound     = Color(0xFF1B5E20);
  static const safeNear      = Color(0xFF43A047);
  static const warningYellow = Color(0xFFFFEB3B);
  static const warningOrange = Color(0xFFFF9800);
  static const alertRed      = Color(0xFFEF5350);
  static const alertRedDark  = Color(0xFFB71C1C);
  static const alertRedDeep  = Color(0xFF8B0000);

  // ── Gold → rimappato su Peach Orange (brand Sonar Cities) ─────────────────
  static const gold          = accent; // alias: stessa costante, cambio semantica visiva

  // ── Distance scale ─────────────────────────────────────────────────────────
  static const dist1         = Color(0xFF43A047); // verde vicino
  static const dist2         = Color(0xFFFFEB3B); // giallo medio
  static const dist3         = Color(0xFFFF9800); // arancio lontano
  static const distFar       = Color(0xFFE64A19); // rosso molto lontano

  // ── Game accents — allineati al brand ─────────────────────────────────────
  // Gioco A: verde (semantico — safe zone)
  static const gameA         = Color(0xFF2E7D32);
  static const gameALight    = Color(0xFF4CAF50);
  // Gioco B: Cosmic Cobalt (colore brand principale)
  static const gameB         = Color(0xFF333399);
  static const gameBLight    = Color(0xFF6666BB);
  // Gioco C: Peach Orange (colore accent brand)
  static const gameC         = Color(0xFFCC8040); // accentDark per contrasto su scuro
  static const gameCLight    = Color(0xFFFFB06C); // accent puro

  // ── Componenti specifici ───────────────────────────────────────────────────
  static const onColored         = Color(0xFFFFFFFF);
  static const hudBackground     = Color(0xE612122A); // bgDark 90% opacità
  static const hudBorder         = Color(0x662A2A55); // border 40%
  static const dialogBackground  = Color(0xFF1A1A35);
  static const dialogBorderEnd   = Color(0xFFB71C1C);
}