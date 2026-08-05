import 'package:aree_attesa_ud/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class GameCard extends StatefulWidget {
  final String label;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color highlightColor;
  final String badgeText;
  final VoidCallback onTap;
  final VoidCallback onGuide;

  const GameCard({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.highlightColor,
    required this.badgeText,
    required this.onTap,
    required this.onGuide,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
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
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withAlpha(128),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withAlpha(38),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardTopRow(
                  label: widget.label,
                  badgeText: widget.badgeText,
                  accentColor: widget.accentColor,
                  highlightColor: widget.highlightColor,
                ),
                const SizedBox(height: 12),
                _CardTitleRow(
                  title: widget.title,
                  icon: widget.icon,
                  accentColor: widget.accentColor,
                  highlightColor: widget.highlightColor,
                ),
                const SizedBox(height: 14),
                Text(widget.description, style: AppTextStyles.gameCardDescription),
                const Spacer(),
                _CardActions(
                  accentColor: widget.accentColor,
                  highlightColor: widget.highlightColor,
                  onGuide: widget.onGuide,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Riga superiore: label + badge ─────────────────────────────────────────────

class _CardTopRow extends StatelessWidget {
  final String label;
  final String badgeText;
  final Color accentColor;
  final Color highlightColor;

  const _CardTopRow({
    required this.label,
    required this.badgeText,
    required this.accentColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.gameCardLabel.copyWith(color: highlightColor),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withAlpha(100)),
          ),
          child: Text(badgeText, style: AppTextStyles.captionWhite),
        ),
      ],
    );
  }
}

// ── Riga titolo: icona + testo ────────────────────────────────────────────────

class _CardTitleRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Color highlightColor;

  const _CardTitleRow({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: accentColor.withAlpha(50),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: highlightColor, size: 28),
        ),
        const SizedBox(width: 16),
        Text(title, style: AppTextStyles.gameCardTitle.copyWith(color: accentColor)),
      ],
    );
  }
}

// ── Riga azioni: "Come si gioca" + "Gioca" ────────────────────────────────────

class _CardActions extends StatelessWidget {
  final Color accentColor;
  final Color highlightColor;
  final VoidCallback onGuide;

  const _CardActions({
    required this.accentColor,
    required this.highlightColor,
    required this.onGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onGuide,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withAlpha(128)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline_rounded,
                    color: highlightColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Come si gioca',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: highlightColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gioca', style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: AppColors.onColored, // sempre bianco su sfondo colorato
                  ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}