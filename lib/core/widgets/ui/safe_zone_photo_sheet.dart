import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../../../features/game_c/photo/game_c_photo_provider.dart';

/// Bottom sheet riusabile per mostrare le foto di un'area di attesa.
///
/// Usa la stessa infrastruttura di Gioco C (AssetPhotoProvider).
/// Chiamare con il metodo statico [show]:
///
/// ```dart
/// SafeZonePhotoSheet.show(
///   context,
///   safeZoneId: zone.id,
///   name: zone.name,
///   address: zone.address,
/// );
/// ```
class SafeZonePhotoSheet extends StatelessWidget {
  final int safeZoneId;
  final String name;
  final String address;
  final GameCPhotoProvider photoProvider;

  const SafeZonePhotoSheet._({
    required this.safeZoneId,
    required this.name,
    required this.address,
    required this.photoProvider,
  });

  /// Apre il bottom sheet. Crea internamente un [AssetPhotoProvider].
  static Future<void> show(
    BuildContext context, {
    required int safeZoneId,
    required String name,
    required String address,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,        // occupa fino all'85% dello schermo
      backgroundColor: Colors.transparent,
      builder: (_) => SafeZonePhotoSheet._(
        safeZoneId: safeZoneId,
        name: name,
        address: address,
        photoProvider: const AssetPhotoProvider(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle ─────────────────────────────────────────────────
          _Handle(),

          // ── Header: nome + indirizzo ────────────────────────────────
          _SheetHeader(name: name, address: address),

          // ── Galleria foto ───────────────────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(1),
              ),
              child: photoProvider.buildPhotoGallery(
                safeZoneId,
                height: double.infinity,
              ),
            ),
          ),

          // ── Spazio sicuro sotto la gesture bar ──────────────────────
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Handle ────────────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final String name;
  final String address;

  const _SheetHeader({required this.name, required this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gameA.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.gameALight,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading3.copyWith(fontSize: 15, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Bottone chiudi
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textDisabled,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
