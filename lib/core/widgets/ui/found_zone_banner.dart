import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../core/widgets/ui/safe_zone_photo_sheet.dart';
/// Mostra un banner temporaneo quando l'utente trova un'area di attesa.
class FoundZoneBanner extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onDismiss;
  final int safeZoneId; 

  const FoundZoneBanner({
    super.key,
    required this.name,
    required this.address,
    required this.onDismiss,
    required this.safeZoneId,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.safeFound, AppColors.gameA],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(102),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.safeNear, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.celebration, color: AppColors.gold, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎉 Area di attesa trovata!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      address,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => SafeZonePhotoSheet.show(
                  context,
                  safeZoneId: safeZoneId,
                  name: name,
                  address: address,
                ),
                icon: const Icon(Icons.photo_library_outlined,
                    color: Colors.white70, size: 20),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
