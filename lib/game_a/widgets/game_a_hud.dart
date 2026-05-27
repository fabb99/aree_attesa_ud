import 'package:flutter/material.dart';
import '../models/game_a_state.dart';
 
class GameAHUD extends StatelessWidget {
  final GameAState state;
  final VoidCallback onEndGame; // callback per il bottone termina
 
  const GameAHUD({super.key, required this.state, required this.onEndGame});
 
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(184),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HUDChip(
                icon: Icons.touch_app,
                label: 'Mosse',
                value: '${state.movesLeft}',
                color: _movesColor(state.movesLeft, state.totalMoves),
              ),
              _divider(),
              _HUDChip(
                icon: Icons.location_on,
                label: 'Trovate',
                value: '${state.foundSafeZones}/${state.totalSafeZones}',
                color: const Color(0xFF4CAF50),
              ),
              _divider(),
              _HUDChip(
                icon: Icons.star,
                label: 'Punti',
                value: '${state.score}',
                color: const Color(0xFFFFD700),
              ),
              _divider(),
 
              // ── Bottone Termina ──────────────────────────────────────
              GestureDetector(
                onTap: onEndGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C).withAlpha(217),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300, width: 0.8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, color: Colors.white, size: 14),
                      SizedBox(height: 2),
                      Text(
                        'Fine',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _divider() => Container(
        width: 1,
        height: 32,
        color: Colors.white24,
      );
 
  Color _movesColor(int left, int total) {
    if (total == 0) return Colors.white;
    final ratio = left / total;
    if (ratio > 0.5) return const Color(0xFF4CAF50);
    if (ratio > 0.25) return const Color(0xFFFFEB3B);
    return const Color(0xFFEF5350);
  }
}
 
class _HUDChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
 
  const _HUDChip({
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
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}