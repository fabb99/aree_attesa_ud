import 'package:flutter/material.dart';
import 'app_colors.dart';


abstract final class AppTextStyles {
  // ── Headings (Da PDF: Roboto Bold, max 3 linee) ───────────────────────────
  static const heading1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700, // Bold
  );

  static const heading3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
  );

  static const heading3App = TextStyle(  
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // ── Subtitles (Da PDF: Roboto Medium) ──────────────────────────────────────
  static const subtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
  );

  // ── Body (Da PDF: Roboto Regular) ──────────────────────────────────────────
  static const body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyWhite = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    height: 1.5,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────

  static const label = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static const labelAccent = TextStyle(  
    color: AppColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
  );

  static const caption = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 12,
  );

  static const captionWhite = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  // ── Buttons ────────────────────────────────────────────────────────────────

  static const button = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const buttonSmall = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // ── Game specifici ─────────────────────────────────────────────────────────

  static const gameCardLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static const gameCardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const gameCardDescription = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 13,
    height: 1.5,
  );

  static const hudValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const hudLabel = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 11,
  );
}





//-------------------
abstract final class AppTextStyles2 {
  // Applica Roboto a tutto 
  static const String _fontFamily = 'Roboto';

  // ── Headings (Da PDF: Roboto Bold, max 3 linee) ───────────────────────────
  static const heading1 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700, // Bold
  );

  static const heading3 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
  );

  // ECCO QUELLO CHE MANCAVA!
  static const heading3App = TextStyle(  
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // ── Subtitles (Da PDF: Roboto Medium) ──────────────────────────────────────
  static const subtitle = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
  );

  // ── Body (Da PDF: Roboto Regular) ──────────────────────────────────────────
  static const body = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyWhite = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textPrimary,
    fontSize: 14,
    height: 1.5,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────

  static const label = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textDisabled,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static const labelAccent = TextStyle(  
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
  );

  static const caption = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textDisabled,
    fontSize: 12,
  );

  static const captionWhite = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  // ── Buttons ────────────────────────────────────────────────────────────────

  static const button = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const buttonSmall = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // ── Game specifici ─────────────────────────────────────────────────────────

  static const gameCardLabel = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static const gameCardTitle = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const gameCardDescription = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textDisabled,
    fontSize: 13,
    height: 1.5,
  );

  static const hudValue = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const hudLabel = TextStyle(
    fontFamily: _fontFamily, // Aggiunto font
    color: AppColors.textDisabled,
    fontSize: 11,
  );
}

//---------------------------------------------
abstract final class AppTextStyles1 {

  // ── Headings ───────────────────────────────────────────────────────────────

  static const heading1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const heading3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const heading3App = TextStyle(  // per l'header app in home
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // ── Body ───────────────────────────────────────────────────────────────────

  static const body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    height: 1.5,
  );

  static const bodyWhite = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    height: 1.5,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────

  static const label = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static const labelAccent = TextStyle(  // per "SCEGLI LA MODALITÀ" ecc.
    color: AppColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
  );

  static const caption = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 12,
  );

  static const captionWhite = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  // ── Buttons ────────────────────────────────────────────────────────────────

  static const button = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const buttonSmall = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // ── Game specifici ─────────────────────────────────────────────────────────

  static const gameCardLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static const gameCardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const gameCardDescription = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 13,
    height: 1.5,
  );

  static const hudValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const hudLabel = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 11,
  );
}
