import 'package:flutter/material.dart';
//-----VERSIONE LIGHT
abstract final class AppColors{
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const bgDeep        = Color(0xFFF0F4F8); // grigio blu molto chiaro
  static const bgDark        = Color(0xFFE8EDF3); // leggermente più scuro
  static const bgCard        = Color(0xFFFFFFFF); // bianco puro
  static const bgCardVariant = Color(0xFFF5F7FA); // bianco sporco

  // ── Primary (blu istituzionale — invariato) ────────────────────────────────
  static const primary       = Color(0xFF1565C0);
  static const primaryDark   = Color(0xFF0D47A1);
  static const primaryLight  = Color(0xFF1E88E5);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF1A2332); // quasi nero blu
  static const textSecondary = Color(0xFF4A5568); // grigio medio
  static const textDisabled  = Color(0xFF9AABBF); // grigio chiaro

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border        = Color(0xFFCDD5E0); // grigio blu chiaro
  static const borderSubtle  = Color(0xFFE2E8F0); // quasi invisibile

  // ── Semantic — identici al dark, non cambiano mai ─────────────────────────
  static const safeFound     = Color(0xFF1B5E20);
  static const safeNear      = Color(0xFF2E7D32);
  static const warningYellow = Color(0xFFF9A825); // leggermente più scuro per contrasto su bianco
  static const warningOrange = Color(0xFFE65100);
  static const alertRed      = Color(0xFFC62828);
  static const alertRedDark  = Color(0xFF8B0000);
  static const alertRedDeep  = Color(0xFF8B0000);
  static const gold          = Color(0xFFF9A825);

  // ── Distance scale ─────────────────────────────────────────────────────────
  static const dist1         = Color(0xFF2E7D32);
  static const dist2         = Color(0xFFF9A825);
  static const dist3         = Color(0xFFE65100);
  static const distFar       = Color(0xFFC62828);

  // ── Game accents ───────────────────────────────────────────────────────────
  static const gameA         = Color(0xFF2E7D32);
  static const gameALight    = Color(0xFF388E3C);
  static const gameB         = Color(0xFF1565C0);
  static const gameBLight    = Color(0xFF1976D2);
  static const gameC         = Color(0xFF6A1B9A);
  static const gameCLight    = Color(0xFF7B1FA2);

  //-----------
  // ── Componenti specifici ───────────────────────────────────────────────────

  /// Testo su sfondi colorati — sempre bianco anche in light
  static const onColored         = Color(0xFFFFFFFF);

  /// Sfondo HUD in light — bianco con alta opacità + ombra
  /// Non semitrasparente come il dark: sulla mappa chiara serve contrasto
  static const hudBackground     = Color(0xF5FFFFFF); // bianco quasi opaco
  static const hudBorder         = Color(0xFFCDD5E0); // bordo grigio visibile

  /// Sfondo dialog
  static const dialogBackground  = Color(0xFFFFFFFF);

  /// Bordo dialog termina — più scuro per visibilità su bianco
  static const dialogBorderEnd   = Color(0xFF2E7D32);
}