import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Widget circolare per mostrare il punteggio (Score Ring).
///
/// Utilizzato nelle schermate di riepilogo di fine partita per fornire 
/// un feedback visivo immediato sul rendimento dell'utente.
class AppScoreRing extends StatelessWidget {
  /// Valore mostrato al centro (es. punteggio, percentuale).
  final int value;

  /// Valore massimo per calcolare il riempimento dell'anello.
  final int maxValue;

  /// Etichetta opzionale sotto il valore (es. "pt").
  final String? sublabel;

  /// Dimensione complessiva del widget (default 100).
  final double size;

  /// Spessore del tratto dell'anello (default 8).
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
    
    // Evita divisioni per zero e garantisce che la barra non superi il 100%
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
            backgroundColor: Colors.black.withAlpha(20),
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
                    color: AppColors.textSecondary
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

  /// Restituisce il colore dell'anello basato sulla percentuale del punteggio.
  static Color _scoreColor(int value, int maxValue) {
    if (maxValue == 0) return AppColors.alertRed;
    
    final pct = value / maxValue;
    if (pct >= 0.6) return AppColors.gameALight;
    if (pct >= 0.3) return AppColors.warningYellow;
    if (pct >= 0.15) return AppColors.warningOrange;
    return AppColors.alertRed;
  }

  /// Utility statica per ottenere il colore del punteggio (utile per colorare le label adiacenti).
  static Color colorFor(int value, int maxValue) => _scoreColor(value, maxValue);
}