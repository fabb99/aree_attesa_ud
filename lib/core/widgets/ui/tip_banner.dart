import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'app_tips.dart';

/// Banner informativo a comparsa sovrapposto alla mappa.
///
/// Utilizzato per mostrare messaggi educativi all'utente durante il gioco 
/// senza interrompere il flusso dell'azione (Non-blocking UI).
class TipBanner extends StatelessWidget {
  final AppTip tip;
  final VoidCallback onDismiss;
  final double topOffset;

  const TipBanner({
    super.key,
    required this.tip,
    required this.onDismiss,
    this.topOffset = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + topOffset,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            color: AppColors.hudBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withAlpha(100),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 1),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tip.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.body,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textDisabled,
                iconSize: 18,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(), // Rimuove il padding extra di default
              ),
            ],
          ),
        ),
      ),
    );
  }
}