import 'package:flutter/material.dart';
import 'app_colors.dart';

//-----VERSIONE DARK
//abstract final class AppTextStylesDark {
abstract final class AppTextStyles {

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

//-----VERSIONE LIGHT


abstract final class AppTextStylesLight {
//abstract final class AppTextStyles {
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

  static const heading3App = TextStyle(
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

  static const labelAccent = TextStyle(
    color: AppColors.gameALight,
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