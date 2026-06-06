import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppResultActions extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onPlayAgain;

  /// Colore del bottone primario "Gioca ancora".
  /// Default: gameB blue. Passa AppColors.gameA per il Gioco A, ecc.
  final Color primaryColor;

  const AppResultActions({
    super.key,
    required this.onHome,
    required this.onPlayAgain,
    this.primaryColor = AppColors.gameB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.home_rounded),
              label: const Text('Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onPlayAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Gioca ancora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}