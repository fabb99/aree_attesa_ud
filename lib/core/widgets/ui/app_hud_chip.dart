import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppHudChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const AppHudChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.hudLabel),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.hudValue.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Divisore verticale standard tra chip nell'HUD.
class AppHudDivider extends StatelessWidget {
  const AppHudDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
    );
  }
}

/// Bottone "Fine" standard nell'HUD — uguale in tutti e tre i giochi.
class AppHudEndButton extends StatelessWidget {
  final VoidCallback onTap;

  const AppHudEndButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.alertRedDark.withAlpha(217),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.alertRed, width: 0.8),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag, color: AppColors.onColored, size: 14),
            SizedBox(height: 2),
            Text(
              'Fine',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onColored,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Container base dell'HUD — sfondo semitrasparente + bordo.
/// Wrappa i chip e li dispone in Row con spaceBetween.
class AppHudContainer extends StatelessWidget {
  final List<Widget> children;

  const AppHudContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.hudBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.hudBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}