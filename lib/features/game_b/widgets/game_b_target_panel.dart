import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/game_b_state.dart';

/// Pannello posizionato in basso nel Gioco B che indica all'utente
/// l'area di attesa da trovare (Nome + Indirizzo) e fornisce feedback
/// se l'utente sbaglia il tocco ("Sei a X celle di distanza!").
class GameBTargetPanel extends StatelessWidget {
  final GameBState state;
  
  /// La distanza (in celle) risultante dall'ultimo tocco errato.
  final int? lastWrongDistance;

  const GameBTargetPanel({
    super.key,
    required this.state,
    required this.lastWrongDistance,
  });

  @override
  Widget build(BuildContext context) {
    final target = state.targetZone!;
    // Se c'è almeno un tocco errato e abbiamo una distanza valida, mostriamo l'alert.
    final hasWrongTap = state.wrongTaps > 0 && lastWrongDistance != null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.gameB, width: 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelHeader(),
            const SizedBox(height: 10),
            Text(
              target.name, 
              style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)
            ),
            const SizedBox(height: 4),
            _AddressRow(address: target.address),
            const SizedBox(height: 16),
            _FeedbackBox(
              hasWrongTap: hasWrongTap,
              lastWrongDistance: lastWrongDistance,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header "TROVA QUEST'AREA" ─────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.gameBLight,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'TROVA QUEST\'AREA DI ATTESA',
          style: AppTextStyles.label.copyWith(
            color: AppColors.gameBLight,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Riga indirizzo ────────────────────────────────────────────────────────────

class _AddressRow extends StatelessWidget {
  final String address;

  const _AddressRow({required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.textDisabled,
          size: 14,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDisabled,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Box feedback tap ──────────────────────────────────────────────────────────

class _FeedbackBox extends StatelessWidget {
  final bool hasWrongTap;
  final int? lastWrongDistance;

  const _FeedbackBox({
    required this.hasWrongTap,
    required this.lastWrongDistance,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasWrongTap ? AppColors.alertRed : AppColors.gameBLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(
            hasWrongTap ? Icons.wrong_location : Icons.touch_app,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasWrongTap
                  ? 'Sei a $lastWrongDistance '
                    'cell${lastWrongDistance == 1 ? 'a' : 'e'} di distanza!'
                  : 'Tocca la cella sulla mappa dove pensi si trovi!',
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: hasWrongTap ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}