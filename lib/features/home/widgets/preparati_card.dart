import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Card interattiva (Call to Action) mostrata nella Home.
/// 
/// Premendola, l'utente può riaprire il flusso di Onboarding per rileggere
/// i contenuti educativi. Gestisce un'animazione di scala per il feedback tattile.
class PreparatiCard extends StatefulWidget {
  final VoidCallback onTap;

  const PreparatiCard({super.key, required this.onTap});

  @override
  State<PreparatiCard> createState() => _PreparatiCardState();
}

class _PreparatiCardState extends State<PreparatiCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentDark.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icona sinistra
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.crisis_alert_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              
              // Testi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preparati all\'emergenza',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 15,
                        color: AppColors.onColored, 
                      ),
                    ),
                    const SizedBox(height: 2),
                     Text(
                      'Le aree di attesa',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onColored.withAlpha(178), 
                      ),
                    ),
                  ],
                ),
              ),
              
              // Freccia destra
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}