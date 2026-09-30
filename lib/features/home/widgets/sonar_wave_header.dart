import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Decorazione grafica a onde (stile "Sonar") utilizzata nell'header della Home.
/// 
/// Sfrutta un [CustomPainter] per sovrapporre tre livelli di onde con profondità
/// e curvature differenti, richiamando l'identità del brand Sonar Cities.
class SonarWaveHeader extends StatelessWidget {
  final Widget child;

  const SonarWaveHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Il Painter che disegna i 3 strati di onda
        Positioned.fill(
          child: CustomPaint(
            painter: _HeaderWavePainter(),
          ),
        ),
        
        // Spazio in basso per permettere alle onde di scendere 
        // senza coprire il contenuto successivo
        Padding(
          padding: const EdgeInsets.only(bottom: 70.0), 
          child: child,
        ),
      ],
    );
  }
}

class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Disegna l'onda Peach Orange (Livello più basso/profondo)
    _drawWave(canvas, size, 0, AppColors.peachOrange);
    
    // Disegna l'onda Dark Grey (Livello intermedio, traslato in alto)
    _drawWave(canvas, size, 12, AppColors.darkGrey);
    
    // Disegna l'onda Cosmic Cobalt (Livello superiore, il più visibile)
    _drawWave(canvas, size, 24, AppColors.cosmicCobalt);
  }

  /// Disegna una singola onda fluida.
  /// 
  /// [upOffset] solleva verticalmente il tracciato per rivelare le onde sottostanti.
  void _drawWave(Canvas canvas, Size size, double upOffset, Color color) {
    const waveHeight = 35.0; // Profondità della curva
    final path = Path();

    // Partiamo da in alto a sinistra e scendiamo
    path.lineTo(0, size.height - waveHeight - upOffset);

    // Curva dell'onda (Stile morbido asimmetrico tramite curva di Bézier cubica)
    path.cubicTo(
      size.width * 0.35, size.height + 15 - upOffset,               // Tira verso il basso a sx
      size.width * 0.65, size.height - (waveHeight * 2.5) - upOffset, // Tira verso l'alto a dx
      size.width, size.height - waveHeight - upOffset,              // Punto di arrivo a dx
    );

    // Risaliamo il lato destro e chiudiamo la forma in alto
    path.lineTo(size.width, 0);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}