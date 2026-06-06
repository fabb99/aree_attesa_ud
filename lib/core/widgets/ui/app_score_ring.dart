import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppScoreRing extends StatelessWidget {
  /// Valore mostrato al centro (es. punteggio, percentuale).
  final int value;

  /// Valore massimo per calcolare la percentuale dell'anello.
  final int maxValue;

  /// Etichetta opzionale sotto il valore (es. "pt").
  final String? sublabel;

  /// Dimensione del widget. Default 100.
  final double size;

  /// Spessore dell'anello. Default 8.
  final double strokeWidth;

  const AppScoreRing({
    super.key,
    required this.value,
    required this.maxValue,
    this.sublabel,
    this.size = 100,
    this.strokeWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(value, maxValue);
    final progress = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: size * 0.26,
                  ),
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Colore dell'anello basato sulla percentuale del punteggio.
  static Color _scoreColor(int value, int maxValue) {
    if (maxValue == 0) return AppColors.alertRed;
    final pct = value / maxValue;
    if (pct >= 0.6) return AppColors.gameALight;
    if (pct >= 0.3) return AppColors.warningYellow;
    if (pct >= 0.15) return AppColors.warningOrange;
    return AppColors.alertRed;
  }

  /// Utility statica — restituisce solo il colore, utile per label esterne.
  static Color colorFor(int value, int maxValue) =>
      _scoreColor(value, maxValue);
}