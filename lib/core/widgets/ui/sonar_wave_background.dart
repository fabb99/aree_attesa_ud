import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SonarWaveBackground extends StatelessWidget {
  final Widget child;

  const SonarWaveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lo sfondo base dell'app (bianco/grigio chiaro)
        Container(color: AppColors.bgDeep),
        
        // Il painter che disegna l'onda blu e arancione
        Positioned.fill(
          child: CustomPaint(
            painter: _SonarWavePainter(),
          ),
        ),
        
        // Il contenuto della tua schermata sopra a tutto
        SafeArea(child: child),
      ],
    );
  }
}

class _SonarWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePath = Path();

    // 1. Iniziamo a disegnare partendo dall'angolo in alto a sinistra
    wavePath.moveTo(0, 0);
    
    // 2. Scendiamo giù lungo il bordo sinistro (fino a circa il 45% dello schermo)
    wavePath.lineTo(0, size.height * 0.45);

    // 3. Disegniamo la curva (S-shape) verso il bordo destro
    // point 1: tira l'onda in basso a sinistra
    // point 2: tira l'onda in alto a destra
    // end point: dove l'onda tocca il bordo destro
    wavePath.cubicTo(
      size.width * 0.4, size.height * 0.55,  // Control Point 1
      size.width * 0.6, size.height * 0.35,  // Control Point 2
      size.width, size.height * 0.40,        // End Point
    );

    // 4. Saliamo lungo il bordo destro fino in cima
    wavePath.lineTo(size.width, 0);
    
    // 5. Chiudiamo il tracciato
    wavePath.close();

    // --- COLORAZIONE ---
    
    // Riempiamo la forma con il Cosmic Cobalt
    final fillPaint = Paint()
      ..color = AppColors.cosmicCobalt
      ..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, fillPaint);

    // Disegniamo il bordo (stroke) con il Peach Orange spesso
    final strokePaint = Paint()
      ..color = AppColors.peachOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0 // Spessore della linea arancione
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(wavePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}